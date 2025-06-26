import {ICommandHandler, ICommandRequest, ICommandResponse} from "@common/utils";

export class FileUploadResponse implements ICommandResponse{}

export class FileUploadRequest implements ICommandRequest<FileUploadResponse>{}

export class FileUploadHandler implements ICommandHandler<FileUploadRequest, FileUploadResponse>{

    async executeAsync(params: FileUploadRequest): Promise<FileUploadResponse> {
        return new FileUploadResponse();
    }
}