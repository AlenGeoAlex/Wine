import {Injectable, Logger} from '@nestjs/common';
import {DatabaseService} from "@db/database";
import {NewUpload, UpdateUpload, Upload} from "common-models/dist/types/uploads.types";
import {ulid} from "ulid";
import {format} from 'date-fns';
import {IServiceOptions} from "common-models";

@Injectable()
export class FileService {

    private readonly logger : Logger = new Logger(FileService.name);

    constructor(
        private readonly databaseService : DatabaseService,
    ) {
    }

    public async createUpload(upload: NewUpload, options?: IServiceOptions) : Promise<{
        id: string,
        fileKey: string,
    }> {
        const db = options?.trx ?? this.databaseService.getDb();
        const id = ulid();
        const fileKey = `${upload.userId}/${format(new Date(), 'yyyy-MM-dd')}/${id}.${upload.extension}`
        await db.insertInto('upload')
            .values({
                id: id,
                fileKey: fileKey,
                userId: upload.userId,
                fileName: upload.fileName,
                extension: upload.extension,
                createdAt: new Date().toISOString(),
                status: 'created',
                size: upload.size,
                tags: upload.tags,
                contentType: upload.contentType,
                expiration: upload.expiration
            })
            .execute();

        return {
            id: id,
            fileKey: fileKey,
        }
    }

    public async updateUploadStatus(id: string, upload: UpdateUpload, options? : IServiceOptions){
        const db = options?.trx ?? this.databaseService.getDb();
        await db.updateTable('upload')
            .set({
                status: upload.status,
            })
            .where('id', '=', id)
            .execute()
    }

    public async getUpload(id: string, options? : IServiceOptions) : Promise<Upload | undefined> {
        const db = options?.trx ?? this.databaseService.getDb();
        return await db.selectFrom('upload')
            .where('id', '=', id)
            .selectAll()
            .executeTakeFirst();
    }

    public async getTotalSizeOfUser(userId: string, options? : IServiceOptions) : Promise<number> {
        const db  = options?.trx ?? this.databaseService.getDb();
        const size = await db.selectFrom('upload')
            .select(({fn, val, ref}) => [
                fn.sum<number>('size').as("totalSize")
            ])
            .where('userId' , '=', userId)
            .executeTakeFirst()

        return size?.totalSize ?? 0;
    }

    public async getUploadByFileKey(fileKey: string, options?: IServiceOptions): Promise<Upload | undefined> {
        const db = options?.trx ?? this.databaseService.getDb();
        return await db.selectFrom('upload')
            .where('fileKey', '=', fileKey)
            .selectAll()
            .executeTakeFirst();
    }

}
