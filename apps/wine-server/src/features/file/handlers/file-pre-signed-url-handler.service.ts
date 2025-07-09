import {
    ForbiddenException,
    Injectable,
    InternalServerErrorException,
    Logger
} from '@nestjs/common';
import {ICommandHandler, ICommandRequest, ICommandResponse} from "@common/utils";
import {FileService} from "@features/file/file.service";
import {S3Service} from "@shared/s3.service";
import {IsOptional} from "class-validator";
import {CONSTANTS} from "@common/constants";
import {ClsService} from "nestjs-cls";
import {DatabaseService} from "@db/database";

export class GeneratedPreSignedUrlResponse implements ICommandResponse {
    url: string[];
    validityInMins: number;


    constructor(url: string[], validityInMins: number) {
        this.url = url;
        this.validityInMins = validityInMins;
    }
}


export type FilePreSignedUrlStatus = 'start' | 'done' | 'error';

export class FilePreSignedUrlCommand implements ICommandRequest<GeneratedPreSignedUrlResponse | boolean>{
    @IsOptional()
    id: string;
    status: FilePreSignedUrlStatus;


    constructor(id: string, status: FilePreSignedUrlStatus) {
        this.id = id;
        this.status = status;
    }
}

@Injectable()
export class FilePreSignedUrlHandler implements ICommandHandler<FilePreSignedUrlCommand, GeneratedPreSignedUrlResponse | boolean>{

    private readonly logger = new Logger(FilePreSignedUrlHandler.name);

    constructor(
        private readonly fileService : FileService,
        private readonly s3Service: S3Service,
        private readonly clsService: ClsService,
        private readonly databaseService: DatabaseService,
    ) {
    }

    async executeAsync(params: FilePreSignedUrlCommand): Promise<GeneratedPreSignedUrlResponse | boolean> {
        const currentUserId = this.clsService.get(CONSTANTS.MIDDLEWARE_KEYS.API_KEY_USER);
        if (!currentUserId) {
            this.logger.warn(`Forbidden: Attempt to access upload without user context.`);
            throw new ForbiddenException('User context is missing.');
        }

        if(params.status === 'start'){
            return this.validateAndGetUploadUrl(params.id, currentUserId)
        }else if(params.status === 'done'){

        }

        return true;
    }

    async validateAndGetUploadUrl(id: string, userId: string): Promise<any> {
        const upload = await this.fileService.validateAndGetFileUploadRequest(id, userId)

        const expiry = this.calculateExpiry(upload.size);
        const presignedUrl = await this.s3Service.generatePresignedUrl(upload.fileKey,expiry, 'POST', upload.contentType, upload.size);
        const transaction = await this.databaseService.transaction();
        try {
            await this.fileService.updateUploadStatus(upload.id, {
                status: "uploading"
            })
            await transaction.commit().execute();
        }catch (e) {
            await transaction.rollback().execute();
            this.logger.warn("Failed to update the database with the new status, Error "+e)
            throw new InternalServerErrorException(e);
        }
        return new GeneratedPreSignedUrlResponse([presignedUrl], expiry);
    }



    private calculateExpiry(fileSizeBytes: number) {
        const MIN_ASSUMED_SPEED_BPS = 50 * 1024;
        const SAFETY_BUFFER_SECONDS = 300;
        const MIN_EXPIRY_SECONDS = 300;
        const MAX_EXPIRY_SECONDS = 3600;

        const estimatedUploadSeconds = fileSizeBytes / MIN_ASSUMED_SPEED_BPS;

        let calculatedExpiry = estimatedUploadSeconds + SAFETY_BUFFER_SECONDS;

        calculatedExpiry = Math.max(calculatedExpiry, MIN_EXPIRY_SECONDS);
        calculatedExpiry = Math.min(calculatedExpiry, MAX_EXPIRY_SECONDS);

        return Math.round(calculatedExpiry);
    }

}
