import {ColumnType, Insertable, Updateable, Selectable, JSONColumnType} from "kysely";

export type UploadStatus = 'created' | 'initiated' | 'uploading' | 'processing' | 'done' | 'cancelled' | 'failed'

export interface UploadTable {
    id: ColumnType<string, string, never>
    fileKey: ColumnType<string, string, never>
    status : UploadStatus
    fileName : ColumnType<string, string, never>
    contentType : ColumnType<string, string, never>
    tags : JSONColumnType<string[]>
    size : ColumnType<number, number, never>
    createdAt: ColumnType<Date, Date | string, never>
    userId: ColumnType<string, string, never>
    extension: ColumnType<string, string, never>
    expiration: ColumnType<Date | undefined, Date | string | undefined, Date | string | undefined>

    // 2025-07-03
    secretHash: ColumnType<string | null, string | undefined, string | undefined>

    // 2025-07-07
    isDeleted: ColumnType<boolean, boolean | number, boolean | number | undefined>
    deletedAt: ColumnType<Date | undefined, Date | string | undefined, Date | string | undefined>
    deletedBy: string | null
}

export type Upload = Selectable<UploadTable>
export type UpdateUpload = Updateable<UploadTable>
export type NewUpload = Insertable<UploadTable>
