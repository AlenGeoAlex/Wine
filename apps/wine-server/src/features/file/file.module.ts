import { Module } from '@nestjs/common';
import {FileService} from "./file.service";
import { FileController } from './file.controller';
import {TusProvider} from "@shared/tus.provider";
import {FileCreateHandler} from "@features/file/handlers/file-create-handler";
import {ClsModule} from "nestjs-cls";
import { FileUploadHandler } from './handlers/file-upload-handler';

@Module({
    providers: [
        FileService,
        TusProvider,
        FileCreateHandler,
        FileUploadHandler
    ],
    controllers: [FileController],
    imports: [
        ClsModule
    ],
    exports: [
        FileService,
        FileUploadHandler
    ]
})
export class FileModule {}
