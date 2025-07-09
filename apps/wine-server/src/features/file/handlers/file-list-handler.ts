import {BadRequestException, Injectable, NotFoundException} from '@nestjs/common';
import {ICommandHandler, ICommandRequest, ICommandResponse, IPaginatedQuery, IPaginatedResponse} from "@common/utils";
import {FileService} from "@features/file/file.service";
import {ClsService} from "nestjs-cls";
import {CONSTANTS} from "@common/constants";
import {UploadStatus} from "common-models";

export interface File {
    id: string,
    expiration: Date | undefined,
    fileName: string,
    size: number,
    status: UploadStatus,
    tags: string[]
    contentType: string;
    createdAt: Date;
}

export class FileListResponse implements ICommandResponse, IPaginatedResponse<File> {
    items: File[] = []
    total: number = 0;
}

export class FileListQuery implements ICommandRequest<FileListResponse>, IPaginatedQuery {
    skip: number = 0;
    take: number = 50;
    userId?: string;
}

@Injectable()
export class FileListHandler implements ICommandHandler<FileListQuery, FileListResponse>{

    constructor(
        private readonly fileService : FileService,
        private readonly clsService: ClsService
    ) {
    }

    async executeAsync(params: FileListQuery): Promise<FileListResponse> {
        const userId = params.userId ?? this.clsService.get(CONSTANTS.MIDDLEWARE_KEYS.API_KEY_USER);
        if(!userId){
            throw new BadRequestException("User not found");
        }
        const fileList = await this.fileService.listUploads(userId, {
            skip: params.skip,
            take: params.take
        });
        const fileListResponse = new FileListResponse();
        fileListResponse.total = fileList.total;
        fileListResponse.items = fileList.uploads;

        return fileListResponse;
    }



}
