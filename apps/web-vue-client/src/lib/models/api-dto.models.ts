export interface IFileInfoResponse {
    id: string;
    name: string;
    size: number;
    expiration: Date | undefined;
    secure: boolean
    status: 'created' | 'initiated' | 'uploading' | 'done' | 'cancelled' | 'failed'
    tags: string[]
    contentType: string;
}

export interface IFileContentResponse {
    content: string
}