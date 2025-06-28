import {ArgumentMetadata, BadRequestException, Injectable, Logger, PipeTransform} from '@nestjs/common';
import {fileTypeFromBuffer} from "file-type";
import {ConfigService} from "@nestjs/config";
import {CONSTANTS} from "@common/constants";

@Injectable()
export class FileTypeValidationPipe implements PipeTransform {

  private readonly allowedMimeTypes: string[];
  private readonly logger = new Logger(FileTypeValidationPipe.name);

  constructor(private readonly configService : ConfigService) {
    const allowedMimeTypes = this.configService.get(CONSTANTS.CONFIG_KEYS.GENERAL.ALLOWED_MIME_TYPES);
    let mimeTypes: string[] | undefined = undefined;
    if(allowedMimeTypes){
      if(typeof allowedMimeTypes === 'string'){
        mimeTypes = allowedMimeTypes.split(',').map(s => s.trim());
      }
    }

    this.allowedMimeTypes = mimeTypes ?? [
      'image/png',
      'image/jpeg',
      'image/webp',
      'video/mp4',
      'video/webm',
    ];
  }

  async transform(value: any, metadata: ArgumentMetadata){
    if (!value || !value.buffer) {
      this.logger.error(`File is missing or unreadable`);
      throw new BadRequestException('File is missing or unreadable');
    }

    const fileType = await fileTypeFromBuffer(value.buffer);

    if (!fileType || !this.allowedMimeTypes.includes(fileType.mime)) {
      this.logger.error(`Unsupported file type, ${fileType?.mime}`);
      throw new BadRequestException(
          `Unsupported file type`
      );
    }

    return value;
  }
}
