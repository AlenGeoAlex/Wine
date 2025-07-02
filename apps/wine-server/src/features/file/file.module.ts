import { Module } from '@nestjs/common';
import {FileService} from "./file.service";
import { FileController } from './file.controller';
import {FileCreateHandler} from "@features/file/handlers/file-create-handler";
import {ClsModule} from "nestjs-cls";
import { FileUploadHandler } from './handlers/file-upload-handler';
import {SharedModule} from "@shared/shared.module";

@Module({
    providers: [
        FileService,
        FileCreateHandler,
        FileUploadHandler
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
