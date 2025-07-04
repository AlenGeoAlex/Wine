import {Injectable, NotFoundException} from '@nestjs/common';
import {ICommandRequest, ICommandResponse, ICommandHandler} from "@common/utils";
import {FileService} from "@features/file/file.service";

export class FileInfoResponse implements ICommandResponse {
    id: string;
    name: string;
    size: number;
    expiration: Date | undefined;
    secure: boolean
    status: 'created' | 'initiated' | 'uploading' | 'done' | 'cancelled' | 'failed'
    tags: string[] = []
    contentType: string;

    constructor(id: string) {
        this.id = id;
    }
}

export class FileInfoCommand implements ICommandRequest<FileInfoResponse> {
    id: string;


    constructor(id: string) {
        this.id = id;
    }
}

@Injectable()
export class FileInfoHandler implements ICommandHandler<FileInfoCommand, FileInfoResponse>{

    constructor(
        private readonly fileService : FileService,

    ) {

    }

    async executeAsync(params: FileInfoCommand): Promise<FileInfoResponse> {
        const fileUpload = await this.fileService.getUpload(params.id);
        if(!fileUpload)
            throw new NotFoundException();

        const fileInfoResponse = new FileInfoResponse(fileUpload.id);
        fileInfoResponse.name = fileUpload.fileName;
        fileInfoResponse.size = fileUpload.size;
        fileInfoResponse.status = fileUpload.status;
        fileInfoResponse.expiration = fileUpload.expiration;
        fileInfoResponse.secure = typeof fileUpload.secretHash === 'string';
        fileInfoResponse.tags = fileUpload.tags ?? [];
        fileInfoResponse.contentType = fileUpload.contentType;
        return fileInfoResponse;
    }

}
