import { Module } from '@nestjs/common';
import {FileService} from "./file.service";
import { FileController } from './file.controller';
import {FileCreateHandler} from "@features/file/handlers/file-create-handler";
import {ClsModule} from "nestjs-cls";
import { FileUploadHandler } from './handlers/file-upload-handler';
import {SharedModule} from "@shared/shared.module";
import { FileContentHandler } from './handlers/file-content-handler.service';
import { FileInfoHandler } from './handlers/file-info-handler';
import { FileListHandler } from './handlers/file-list-handler';
import { FileDeleteHandler } from './handlers/file-delete-handler';
import { FileEventListener } from './listeners/file-event-listener';
import { FilePreSignedUrlHandler } from './handlers/file-pre-signed-url-handler.service';

@Module({
    providers: [
        FileService,
        FileCreateHandler,
        FileUploadHandler,
        FileContentHandler,
        FileInfoHandler,
        FileListHandler,
        FileDeleteHandler,
        FileEventListener,
        FilePreSignedUrlHandler
    ],
    controllers: [FileController],
    imports: [
        ClsModule,
        SharedModule
    ],
    exports: [
        FileService,
        FileUploadHandler
    ]
})
export class FileModule {}
