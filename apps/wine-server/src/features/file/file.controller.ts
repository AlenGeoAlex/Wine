import {Controller, Logger, Post, Req, Res} from '@nestjs/common';
import {FileService} from "./file.service";
import {TusProvider} from "../../shared/tus.provider";
import { Request, Response } from 'express';

@Controller('file')
export class FileController {

    private readonly logger = new Logger(FileController.name);

    constructor(
        private readonly fileService: FileService,
        private readonly tusProvider : TusProvider
    ) {
    }

    @Post()
    public async upload(@Req() req: Request, @Res() res: Response) {
        this.logger.log('upload called');
        return this.tusProvider.tus.handle(req, res)
    }

}
