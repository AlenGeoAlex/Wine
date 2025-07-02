import { Injectable, Logger, NotFoundException, ForbiddenException, ConflictException } from '@nestjs/common';
import { ClsService } from 'nestjs-cls';
import { FileService } from '@features/file/file.service';
import { CONSTANTS } from '@common/constants';
import {ICommandHandler, ICommandRequest, ICommandResponse} from "@common/utils";
import {FileSaverProvider} from "@shared/file-saver.provider";
import {Upload} from "common-models";
import {ConfigService} from "@nestjs/config";

export class FileUploadCommand implements ICommandRequest<FileUploadResponse> {
    uploadId: string;
    buffer: Buffer;

    constructor(uploadId: string, buffer: Buffer) {
        this.uploadId = uploadId;
        this.buffer = buffer;
    }
}

export class FileUploadResponse implements ICommandResponse{
    domain?: string;
    fileId: string;
}


@Injectable()
export class FileUploadHandler implements ICommandHandler<FileUploadCommand, FileUploadResponse>{
    private readonly logger = new Logger(FileUploadHandler.name);

    constructor(
        private readonly clsService: ClsService,
        private readonly fileService: FileService,
        private readonly fileSaverProvider : FileSaverProvider,
        private readonly configService: ConfigService,
    ) {}

    /**
     * Validates an incoming TUS request against business rules.
     * Throws an appropriate HTTP exception if validation fails.
     * @param uploadId The ID of the upload being accessed.
     */
    private async validateAndGetUpload(uploadId: string): Promise<Upload> {
        this.logger.debug(`Validating request for upload ID: ${uploadId}`);

        const currentUserId = this.clsService.get(CONSTANTS.MIDDLEWARE_KEYS.API_KEY_USER);
        if (!currentUserId) {
            this.logger.warn(`Forbidden: Attempt to access upload without user context.`);
            throw new ForbiddenException('User context is missing.');
        }

        const upload = await this.fileService.getUpload(uploadId);
        if (!upload) {
            this.logger.warn(`Not Found: Attempt to access non-existent upload ID: ${uploadId}`);
            throw new NotFoundException(`Upload with ID ${uploadId} not found.`);
        }

        if (upload.userId !== currentUserId) {
            this.logger.warn(`Forbidden: User ${currentUserId} attempted to access upload ${uploadId} owned by ${upload.userId}.`);
            throw new ForbiddenException('You do not have permission to access this upload.');
        }

        if (upload.status === 'done') {
            this.logger.warn(`Conflict: Attempt to modify already completed upload ${uploadId}.`);
            throw new ConflictException('This upload has already been completed and cannot be modified.');
        }

        if (upload.status === 'failed') {
            this.logger.warn(`Conflict: Attempt to modify failed upload ${uploadId}.`);
            throw new ConflictException('This upload has failed and cannot be modified.');
        }

        this.logger.debug(`Validation successful for upload ID: ${uploadId}`);
        return upload;
    }

    async executeAsync(params: FileUploadCommand): Promise<FileUploadResponse> {
        const upload = await this.validateAndGetUpload(params.uploadId)
        const fileKey = upload.fileKey;
        const fileKeyParts = fileKey.split("/");
        const fileName = fileKeyParts.pop()!;
        const response = await this.fileSaverProvider.uploadFile("", fileName, params.buffer);
        this.logger.log(`Uploaded file ${fileKey} to ${response}`);

        await this.fileService.updateUploadStatus(upload.id, {
            status: 'done'
        });
        const fileUploadResponse = new FileUploadResponse();
        fileUploadResponse.domain = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.GENERAL.BASE_DOMAIN) ?? "";
        fileUploadResponse.fileId = upload.id.toLowerCase();
        this.logger.log(`File upload completed for upload ${upload.id} with fileId ${fileUploadResponse.fileId} and domain ${fileUploadResponse.domain}`)
        return fileUploadResponse
    }
}