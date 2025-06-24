import {ColumnType, Insertable, Updateable, Selectable, JSONColumnType} from "kysely";

export interface UploadTable {
    id: ColumnType<string, string, never>
    fileKey: ColumnType<string, string, never>
    status : 'created' | 'initiated' | 'uploading' | 'done' | 'cancelled' | 'failed'
    fileName : ColumnType<string, string, never>
    contentType : ColumnType<string, string, never>
    tags : JSONColumnType<string[]>
    size : ColumnType<number, number, never>
    createdAt: ColumnType<Date, Date | string, never>
}

export type Upload = Selectable<UploadTable>
export type UpdateUpload = Updateable<UploadTable>
export type NewUpload = Insertable<UploadTable>
