import {ForbiddenException, Injectable, Logger, NotFoundException} from '@nestjs/common';
import {ICommandHandler, ICommandRequest, ICommandResponse} from "@common/utils";
import {FileService} from "@features/file/file.service";
import {ConfigService} from "@nestjs/config";
import {CryptoService} from "@shared/crypto.service";
import {CONSTANTS} from "@common/constants";
import {StorageProvider} from "@common/enums";
import {S3Service} from "@shared/s3.service";
import * as path from 'path';

export class FileContentResponse implements ICommandResponse {
    filePath?: string;
    redirect?: string;
    contentType?: string;
    fileName?: string

    constructor(filePath?: string, redirect?: string) {
        this.filePath = filePath;
        this.redirect = redirect;
    }
}

export class FileContentCommand implements ICommandRequest<FileContentCommand>{
    fileId: string;
    secret?: string;


    constructor(fileId: string, secret?: string) {
        this.fileId = fileId;
        this.secret = secret;
    }
}

@Injectable()
export class FileContentHandler implements ICommandHandler<FileContentCommand, FileContentResponse>{

    private readonly logger = new Logger(FileContentHandler.name);

    constructor(
        private readonly fileService : FileService,
        private readonly configService : ConfigService,
        private readonly cryptoService : CryptoService,
        private readonly s3Service : S3Service,
    ) {

    }

    async executeAsync(params: FileContentCommand): Promise<FileContentResponse> {
        const fileUpload = await this.fileService.getUpload(params.fileId.toUpperCase());
        if(!fileUpload){
            this.logger.error(`File with id ${params.fileId} not found`);
            throw new NotFoundException();
        }

        if(fileUpload.status !== 'done'){
            this.logger.error(`File with id ${params.fileId} is not ready`);
            throw new NotFoundException();
        }

        if(fileUpload.expiration && fileUpload.expiration.getTime() < Date.now()){
            this.logger.error(`File with id ${params.fileId} expired`);
            throw new NotFoundException();
        }

        if (fileUpload.secretHash) {
            if (!params.secret) {
                this.logger.error(`A secret is required to unlock ${fileUpload.fileName ?? "this file"}!`);
                throw new ForbiddenException(`A secret mixture is required to unlock ${fileUpload.fileName ?? "this file"}!.`);
            }

            const isValidSecret = await this.cryptoService.compare(params.secret, fileUpload.secretHash);

            if (!isValidSecret) {
                this.logger.error(`Invalid secret for file ${fileUpload.fileName ?? "this file"}!`);
                throw new ForbiddenException('Invalid secret.');
            }
        }

        const fs = this.configService.get(CONSTANTS.CONFIG_KEYS.STORAGE.STORAGE_PROVIDER, StorageProvider.FS) as StorageProvider;
        if(fs === StorageProvider.FS){
            const rootPath = this.configService.get<string>(
                CONSTANTS.CONFIG_KEYS.STORAGE.FS.FS_FILE_PATH,
            );

            if (!rootPath) {
                this.logger.error('Storage path not configured');
                throw new Error('Storage path not configured');
            }

            const absolutePath = path.join(rootPath, fileUpload.fileKey);
            this.logger.log(`File ${fileUpload.fileName} would be streamed from ${absolutePath}`);
            const fileContentResponse = new FileContentResponse(absolutePath, undefined);
            fileContentResponse.contentType = fileUpload.contentType;
            fileContentResponse.fileName = fileUpload.fileName;
            return fileContentResponse;
        }else{
            const presignedUrl = await this.s3Service.generatePresignedUrl(fileUpload.fileKey, 60, 'GET');
            this.logger.log(`File ${fileUpload.fileName} presigned url generated`);
            return new FileContentResponse(undefined, presignedUrl);
        }
    }



}
