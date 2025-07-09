import {
    Injectable,
    Logger,
    NotFoundException,
    ForbiddenException,
    ConflictException,
    InternalServerErrorException
} from '@nestjs/common';
import { ClsService } from 'nestjs-cls';
import { FileService } from '@features/file/file.service';
import { CONSTANTS } from '@common/constants';
import {ICommandHandler, ICommandRequest, ICommandResponse} from "@common/utils";
import {FileSaverProvider} from "@shared/file-saver.provider";
import {Upload} from "common-models";
import {ConfigService} from "@nestjs/config";
import {DatabaseService} from "@db/database";

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
        private readonly databaseService: DatabaseService,
    ) {}


    /**
     * Executes the asynchronous file upload process, handles database transactions, and manages file upload state.
     *
     * @param {FileUploadCommand} params - The parameters required for executing the file upload, including the upload ID and file buffer.
     * @return {Promise<FileUploadResponse>} - A promise that resolves to the response containing file upload details, such as the domain and file ID.
     */
    async executeAsync(params: FileUploadCommand): Promise<FileUploadResponse> {
        const currentUserId = this.clsService.get(CONSTANTS.MIDDLEWARE_KEYS.API_KEY_USER);
        if (!currentUserId) {
            this.logger.warn(`Forbidden: Attempt to access upload without user context.`);
            throw new ForbiddenException('User context is missing.');
        }

        const upload = await this.fileService.validateAndGetFileUploadRequest(params.uploadId, currentUserId)

        {
            const transaction = await this.databaseService.transaction();
            try {
                await this.fileService.updateUploadStatus(upload.id, {
                    status: "uploading"
                });
                await transaction.commit().execute();
            }catch (e) {
                await transaction.rollback().execute();
                this.logger.warn("Failed to update the database with the new status, Error "+e)
                throw new InternalServerErrorException(e);
            }
        }

        const fileKey = upload.fileKey;
        const fileKeyParts = fileKey.split("/");
        const fileName = fileKeyParts.pop()!;
        const response = await this.fileSaverProvider.uploadFile(fileKeyParts, fileName, params.buffer);
        this.logger.log(`Uploaded file ${fileKey} to ${response}`);

        {
            const transaction = await this.databaseService.transaction();
            try {
                await this.fileService.updateUploadStatus(upload.id, {
                    status: 'done'
                });
                await transaction.commit().execute();
            }catch (e){
                //TODO send an event to clean it
                await transaction.rollback().execute();
                this.logger.warn("Failed to update the database with the new status, Error "+e)
                throw new InternalServerErrorException(e);
            }
        }

        const fileUploadResponse = new FileUploadResponse();
        fileUploadResponse.domain = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.GENERAL.BASE_DOMAIN) ?? "";
        fileUploadResponse.fileId = upload.id.toLowerCase();
        this.logger.log(`File upload completed for upload ${upload.id} with fileId ${fileUploadResponse.fileId} and domain ${fileUploadResponse.domain}`)
        return fileUploadResponse
    }
}