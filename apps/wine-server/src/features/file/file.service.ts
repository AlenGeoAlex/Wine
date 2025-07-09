import {ConflictException, Injectable, Logger, NotFoundException} from '@nestjs/common';
import {DatabaseService} from "@db/database";
import {ulid} from "ulid";
import {format} from 'date-fns';
import {IServiceOptions, NewUpload, UpdateUpload, Upload} from "common-models";
import {IPaginatedQuery} from "@common/utils";

@Injectable()
export class FileService {

    private readonly logger : Logger = new Logger(FileService.name);

    constructor(
        private readonly databaseService : DatabaseService,
    ) {
    }

    /**
     * Fetches a list of uploads for a given user with optional filtering parameters.
     *
     * @param {string} userId - The ID of the user whose uploads will be listed.
     * @param {ListUploadsOptions} [options] - Optional parameters for filtering and pagination.
     *      - `skip` specifies the number of uploads to skip (default is 0).
     *      - `take` specifies the number of uploads to fetch (default is 20).
     *      - `includeDeleted` determines whether to include deleted uploads in the results (default is false).
     *      - `trx` allows a transaction context to be passed for database operations.
     * @return {Promise<{uploads: Upload[], total: number}>} A promise that resolves with an object containing:
     *      - `uploads`: An array of upload records.
     *      - `total`: The total number of uploads.
     */
    public async listUploads(userId: string, options?: ListUploadsOptions) : Promise<{
        uploads: Upload[],
        total: number,
    }> {
        const db = options?.trx ?? this.databaseService.getDb();
        const skip = options?.skip ?? 0;
        const take = options?.take ?? 20;
        const includeDeleted = options?.includeDeleted ?? false;
        let selectQueryBuilder = db.selectFrom('upload')
            .selectAll('upload')
            .select(
                (eb) => eb.fn.countAll().over().as('total_count')
            )
            .where('userId', '=', userId);

        if(!includeDeleted)
            selectQueryBuilder = selectQueryBuilder
                .where('isDeleted','=', false)

        const rows = await selectQueryBuilder
            .where('isDeleted', '=', false)
            .offset(skip)
            .limit(take)
            .orderBy('createdAt', 'desc')
            .execute();

        const total = rows.length > 0 ? Number((rows[0] as any).total_count) : 0;
        const uploads = rows.map(({ total_count, ...rest }) => rest as Upload);
        return {
            uploads,
            total,
        };
    }

    /**
     * Creates a new upload record in the database and generates a unique file key.
     *
     * @param {NewUpload} upload - The upload object containing details such as userId, file name, extension, size, tags, content type, and expiration.
     * @param {IServiceOptions} [options] - Optional service options, including a transaction object to use when interacting with the database.
     * @return {Promise<{id: string, fileKey: string}>} A promise that resolves to an object containing the generated upload ID and file key.
     */
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
                tags: JSON.stringify(upload.tags ?? []),
                contentType: upload.contentType,
                expiration: upload.expiration instanceof Date ? upload.expiration.toISOString() : upload.expiration,
                isDeleted: this.databaseService.parseBoolean(false),
            })
            .execute();

        return {
            id: id,
            fileKey: fileKey,
        }
    }

    /**
     * Updates the upload status of a specific record in the database.
     *
     * @param {string} id - The unique identifier of the upload record to update.
     * @param {UpdateUpload} upload - An object containing the updated upload status.
     * @param {IServiceOptions} [options] - Additional service options, including a transaction object.
     * @return {Promise<void>} A promise that resolves when the upload status is updated successfully.
     */
    public async updateUploadStatus(id: string, upload: UpdateUpload, options? : IServiceOptions){
        const db = options?.trx ?? this.databaseService.getDb();
        await db.updateTable('upload')
            .set({
                status: upload.status,
            })
            .where('id', '=', id)
            .execute()
    }

    /**
     * Retrieves an upload record from the database based on the provided identifier.
     *
     * @param {string} id - The unique identifier of the upload to retrieve.
     * @param {GetUploadOptions} [options] - Optional parameters to customize the behavior of the query. This includes:
     *   - `trx`: A database transaction to be used for the query.
     *   - `userId`: A filter to fetch the upload belonging to a specific user.
     *   - `includeDeleted`: A flag to include deleted uploads in the result if set to true.
     * @return {Promise<Upload | undefined>} A promise that resolves to the upload record if found, or undefined if no record matches the criteria.
     */
    public async getUpload(id: string, options? : GetUploadOptions) : Promise<Upload | undefined> {
        const db = options?.trx ?? this.databaseService.getDb();
        let selectQueryBuilder = db.selectFrom('upload')
            .where('id', '=', id.toUpperCase());

        if(options?.userId)
            selectQueryBuilder = selectQueryBuilder
                .where('userId', '=', options?.userId);

        if(!options?.includeDeleted)
            selectQueryBuilder = selectQueryBuilder
                .where('isDeleted', '=', false);

        return await selectQueryBuilder
            .selectAll()
            .executeTakeFirst();
    }

    /**
     * Calculates the total size of uploads for a given user.
     *
     * @param {string} userId - The unique identifier of the user whose total upload size is to be calculated.
     * @param {IServiceOptions} [options] - Optional parameter that contains additional service options, including a transaction object for database operations.
     * @return {Promise<number>} A promise that resolves to the total size of the user's uploads in bytes. Returns 0 if no uploads are found.
     */
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

    /**
     * Deletes an upload by marking it as deleted in the database.
     *
     * @param {string} id - The unique identifier of the upload to be deleted.
     * @param {string} deletedBy - The identifier of the user or system responsible for the deletion. Must not be empty.
     * @param {IServiceOptions} [options] - Optional service options, including transaction management.
     * @return {Promise<void>} A promise that resolves when the operation is complete.
     * @throws {Error} If the `deletedBy` parameter is an empty string.
     */
    public async deleteUpload(id: string, deletedBy: string, options? : IServiceOptions) : Promise<void> {
        const db = options?.trx ?? this.databaseService.getDb();
        if(deletedBy.trim().length === 0)
            throw new Error("Deleted by cannot be empty");

        await db.updateTable('upload')
            .set({
                isDeleted: true,
                deletedBy: deletedBy,
                deletedAt: new Date().toISOString(),
            })
            .where('id', '=', id)
            .where('isDeleted', '=', false)
            .execute();
    }

    /**
     * Deletes a record from the "upload" table permanently based on the provided ID.
     *
     * @param {string} id - The unique identifier for the record to delete.
     * @param {IServiceOptions} [options] - Optional service options, which may include a transaction context.
     * @return {Promise<void>} A promise that resolves when the deletion is complete.
     */
    public async hardDeleteAsync(id: string, options? : IServiceOptions): Promise<void>{
        const db = options?.trx ?? this.databaseService.getDb();
        await db.deleteFrom('upload')
            .where('id', '=', id)
            .execute();
    }

    /**
     * Validates the upload request for a given file and user, and retrieves the file upload details.
     * Ensures that the file upload record exists, has not been completed, failed, deleted, or is in an invalid state.
     *
     * @param {string} fileId - The unique identifier for the file upload.
     * @param {string} userId - The unique identifier of the user associated with the file upload.
     * @param {IServiceOptions} [options] - Optional service options that may be used for the request.
     * @return {Promise<Upload>} A promise that resolves with the file upload details if validation passes.
     * @throws {NotFoundException} If no upload with the given file ID exists for the specified user.
     * @throws {ConflictException} If the upload has already completed, failed, been deleted, or is in an invalid state.
     */
    public async validateAndGetFileUploadRequest(fileId: string, userId: string, options?: IServiceOptions) : Promise<Upload> {
        const upload = await this.getUpload(fileId, {
            userId: userId,
        });

        if(!upload){
            this.logger.error(`Upload ${fileId} not found for user ${userId}`);
            throw new NotFoundException(`Upload ${fileId} not found for user ${userId}`);
        }

        if (upload.status === 'done') {
            this.logger.warn(`Conflict: Attempt to modify already completed upload ${upload.id}.`);
            throw new ConflictException('This upload has already been completed and cannot be modified.');
        }

        if (upload.status === 'failed') {
            this.logger.warn(`Conflict: Attempt to modify failed upload ${upload.id}.`);
            throw new ConflictException('This upload has failed and cannot be modified.');
        }

        if(upload.isDeleted){
            this.logger.warn(`Conflict: Attempt to modify deleted upload ${upload.id}.`);
            throw new ConflictException('This upload has been deleted and cannot be modified.');
        }

        if(!['created' , 'initiated' , 'uploading'].includes(upload.status)){
            this.logger.warn(`Conflict: Attempt to modify upload ${upload.id} in invalid state ${upload.status}.`);
            throw new ConflictException('This upload is in an invalid state and cannot be modified.');
        }

        return upload;
    }
}

interface GetUploadOptions extends IServiceOptions {
    userId?: string;
    includeDeleted?: boolean;
}

interface ListUploadsOptions extends IServiceOptions, IPaginatedQuery {
    includeDeleted?: boolean;
}
