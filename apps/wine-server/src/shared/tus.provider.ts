import {Injectable, Logger} from '@nestjs/common';
import {Server} from "@tus/server";
import {FileStore} from "@tus/file-store";
import {ConfigService} from "@nestjs/config";
import {CONSTANTS} from "@common/constants";
import {StorageProvider} from "@common/enums";
import {S3Store} from "@tus/s3-store";
import * as path from 'path';

@Injectable()
export class TusProvider {

    private readonly logger = new Logger(TusProvider.name);
    private readonly tusServer : Server;

    constructor(
        private readonly configService : ConfigService
    ) {
        const provider = configService.get<string>(CONSTANTS.CONFIG_KEYS.STORAGE.STORAGE_PROVIDER) ?? StorageProvider.FS;
        this.logger.log(`TusProvider initialized with provider ${provider}`);
        this.tusServer = new Server({
            path: '/files',
            datastore: this.initializeDataStore(provider as StorageProvider)
        })
    }

    public get tus() : Server {
        return this.tusServer;
    }

    private initializeDataStore(storageProvider : StorageProvider){
        switch (storageProvider) {
            case StorageProvider.FS:
                const defaultDirArray = CONSTANTS.DEFAULTS.DEFAULT_DATA_DIRECTORY;
                const defaultPath = path.join(...defaultDirArray, "uploads");
                this.logger.log(`Using file system storage at ${defaultPath}`);
                const filePath = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.STORAGE.FS.FS_FILE_PATH) ?? defaultPath;
                return new FileStore({
                    directory: filePath
                });
            case StorageProvider.S3:
            case StorageProvider.R2:
                const bucket = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_BUCKET);
                const region = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_REGION);
                const accessKey = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_ACCESS_KEY);
                const secretKey = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_SECRET_KEY);
                const endpoint = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_ENDPOINT);
                const partSize = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_PART_SIZE) ?? "10485760";

                if(!bucket)
                    throw new Error("S3 bucket is not set");

                if(!accessKey)
                    throw new Error("S3 region is not set");

                if(!secretKey)
                    throw new Error("S3 secret key is not set");

                if(!endpoint && !region)
                    throw new Error("S3 endpoint or region should be set");

                if(!Number.isFinite(partSize))
                    throw new Error("S3 part size is not a number");

                const partSizeNumber = Number.parseInt(partSize);

                return new S3Store({
                    minPartSize: storageProvider === StorageProvider.R2 ? partSizeNumber : undefined,
                    partSize: partSizeNumber,
                    s3ClientConfig: {
                        bucket: bucket,
                        endpoint: endpoint,
                        region: region,
                        credentials: {
                            accessKeyId: accessKey,
                            secretAccessKey: secretKey,
                        }
                    }
                })
            default:
                throw new Error(`Storage provider ${storageProvider} is not supported`);
        }
    }

}
