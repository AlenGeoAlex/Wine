import {ICommandHandler, ICommandRequest, ICommandResponse, IErrorResponse} from "@common/utils";
import {Injectable, Logger, UnauthorizedException} from "@nestjs/common";
import {FileService} from "@features/file/file.service";
import {DatabaseService} from "@db/database";
import {ClsService} from "nestjs-cls";
import {CONSTANTS} from "@common/constants";
import {ConfigService} from "@nestjs/config";
import {StorageProvider} from "@common/enums";
import {IsNotEmpty, IsOptional, Min, MinLength} from "class-validator";
import {CryptoService} from "@shared/crypto.service";
import {EventEmitter2} from "@nestjs/event-emitter";
import {FileCreatedEvent} from "@features/file/events.file";
import {Type} from "class-transformer";

export class FileCreateResponse implements ICommandResponse{
    id: string
    uploadType : 'direct' | 'presigned'


    constructor(id: string, uploadType: "direct" | "presigned") {
        this.id = id;
        this.uploadType = uploadType;
    }
}

export class FileCreateRequest implements ICommandRequest<FileCreateResponse>{
    @IsNotEmpty()
    fileName: string

    @IsNotEmpty()
    extension: string

    @Min(1)
    @IsNotEmpty()
    size: number

    @IsOptional()
    tags: string[] = []

    @IsNotEmpty()
    contentType: string

    @IsOptional()
    @Type(() => Date)
    expiration: Date | undefined

    @IsOptional()
    @MinLength(4, { message: 'Secret must be at least 4 characters long' })
    secret?: string | undefined;
}

export class FileCreateError implements IErrorResponse {
    code: number
    message: string
    meta?: Record<string, string>


    constructor(code: number, message: string) {
        this.code = code;
        this.message = message;
    }
}

@Injectable()
export class FileCreateHandler implements ICommandHandler<FileCreateRequest, FileCreateResponse | FileCreateError>{

    private readonly logger : Logger = new Logger(FileCreateHandler.name);

    constructor(
        private readonly clsService : ClsService,
        private readonly databaseService : DatabaseService,
        private readonly fileService : FileService,
        private readonly configService : ConfigService,
        private readonly cryptoService : CryptoService,
        private readonly eventEmitter: EventEmitter2
    ) {
    }


    async executeAsync(params: FileCreateRequest): Promise<FileCreateResponse | FileCreateError> {
        const userId = this.clsService.get(CONSTANTS.MIDDLEWARE_KEYS.API_KEY_USER);
        if(!userId)
            throw new UnauthorizedException("Unknown user");

        if(params.expiration && params.expiration.getTime() < Date.now())
            return new FileCreateError(
                400,
                "Expiration date is in the past"
            )

        let secretHash: string | undefined = undefined;
        if (params.secret) {
            if (params.secret.length < 4) {
                return new FileCreateError(400, "Secret must be at least 4 characters long");
            }
            secretHash = await this.cryptoService.hash(params.secret);
        }

        const transaction = await this.databaseService.transaction();
        try {

            const fileCreationResponse = await this.fileService.createUpload({
                id: '',
                userId: userId,
                fileName: params.fileName,
                contentType: params.contentType,
                expiration: params.expiration,
                extension: params.extension,
                fileKey: '',
                tags: JSON.stringify(params.tags ?? []),
                size: params.size,
                createdAt: new Date(),
                status: 'created',
                secretHash: secretHash,
                isDeleted: false
            }, {
                trx: transaction
            })

            await transaction.commit().execute();
            let uploadType : 'direct' | 'presigned' = 'direct';
            const storageProvider = this.configService.get(CONSTANTS.CONFIG_KEYS.STORAGE.STORAGE_PROVIDER, StorageProvider.FS) as StorageProvider;
            if(storageProvider !== StorageProvider.FS)
                uploadType = 'presigned';

            this.eventEmitter.emit('file.created', new FileCreatedEvent(
                fileCreationResponse.id,
                FileCreateHandler.name,
                params.secret !== undefined,
                params.contentType))

            return new FileCreateResponse(
                fileCreationResponse.id,
                uploadType,
            )
        }catch (e) {
            await transaction.rollback().execute();
            this.logger.error(e);
            return new FileCreateError(
                500,
                 "Failed to create upload",
            );
        }
    }
}