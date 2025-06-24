import { Module } from '@nestjs/common';
import {FileService} from "./file.service";
import { FileController } from './file.controller';
import {TusProvider} from "../../shared/tus.provider";

@Module({
    providers: [
        FileService,
        TusProvider
    ],
    controllers: [FileController],
})
export class FileModule {}
