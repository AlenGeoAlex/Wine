import { Injectable, Logger, NotFoundException, ForbiddenException, ConflictException } from '@nestjs/common';
import { ClsService } from 'nestjs-cls';
import { FileService } from '@features/file/file.service';
import { CONSTANTS } from '@common/constants';

@Injectable()
export class FileUploadHandler {
    private readonly logger = new Logger(FileUploadHandler.name);

    constructor(
        private readonly clsService: ClsService,
        private readonly fileService: FileService,
    ) {}

    /**
     * Validates an incoming TUS request against business rules.
     * Throws an appropriate HTTP exception if validation fails.
     * @param uploadId The ID of the upload being accessed.
     */
    public async validateRequest(uploadId: string): Promise<void> {
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
    }
}