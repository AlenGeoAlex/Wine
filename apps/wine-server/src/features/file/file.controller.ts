import {
    BadRequestException,
    Body,
    Controller,
    Get,
    HttpCode,
    Logger,
    NotFoundException,
    Param,
    Post,
    Req,
    Res, StreamableFile,
    UploadedFile,
    UseInterceptors,
    UsePipes
} from '@nestjs/common';
import {Response} from 'express';
import {FileCreateHandler, FileCreateRequest, FileCreateResponse} from "@features/file/handlers/file-create-handler";
import {FileTypeValidationPipe} from "@/pipes/file-type-validation.pipe";
import {CustomFileInterceptor} from "@/interceptor/custom-file.interceptor";
import {FileUploadCommand, FileUploadHandler} from "@features/file/handlers/file-upload-handler";
import {FileContentHandler, FileContentCommand} from "@features/file/handlers/file-content-handler.service";
import {FileInfoCommand, FileInfoHandler} from "@features/file/handlers/file-info-handler";
import {createReadStream, statSync} from "node:fs";
import {statfsSync} from "fs";


@Controller('api/v1/file')
export class FileController {

    private readonly logger = new Logger(FileController.name);

    constructor(
        private readonly fileCreateHandler : FileCreateHandler,
        private readonly fileUploadHandler : FileUploadHandler,
        private readonly fileContentHandler : FileContentHandler,
        private readonly fileInfoHandler: FileInfoHandler
    ) {
    }

    @Post()
    public async post(@Body() command: FileCreateRequest, @Res() res: Response){
        this.logger.log(`File upload request: ${JSON.stringify(command)}`);
        const fileUploadResponse = await this.fileCreateHandler.executeAsync(command);
        this.logger.log(`File upload response: ${JSON.stringify(fileUploadResponse)}`);
        if(fileUploadResponse instanceof FileCreateResponse){
            return res.status(201).json(fileUploadResponse);
        }else {
            return res.status(fileUploadResponse.code).json(fileUploadResponse);
        }
    }


    @Get(':id/content')
    public async get(@Param('id') id: string, @Res() res: Response, @Req() req: Request) {
        if (!id || id.trim().length === 0) {
            throw new BadRequestException("Id is required");
        }

        const fileSecret = req.headers['x-file-secret'] as string | undefined;
        const getResponse = await this.fileContentHandler.executeAsync(new FileContentCommand(id, fileSecret));

        if (getResponse.redirect) {
            return res.redirect(getResponse.redirect);
        }

        if (!getResponse.filePath) {
            throw new NotFoundException();
        }

        try {
            const stat = statSync(getResponse.filePath); // ✅ actual file size
            const fileSize = stat.size;
            const range = req.headers["range"];

            if (range) {
                // Example: "bytes=0-"
                const parts = range.replace(/bytes=/, '').split('-');
                const start = parseInt(parts[0], 10);
                const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;

                if (start >= fileSize || isNaN(start)) {
                    res.writeHead(416, {
                        'Content-Range': `bytes */${fileSize}`,
                    });
                    return res.end();
                }

                const chunkSize = (end - start) + 1;
                const stream = createReadStream(getResponse.filePath, { start, end });

                res.writeHead(206, {
                    'Content-Range': `bytes ${start}-${end}/${fileSize}`,
                    'Accept-Ranges': 'bytes',
                    'Content-Length': chunkSize,
                    'Content-Type': 'video/mp4',
                });

                return stream.pipe(res);
            }

            res.writeHead(200, {
                'Content-Length': fileSize,
                'Content-Type': getResponse.contentType,
            });

            return createReadStream(getResponse.filePath).pipe(res);
        } catch (e) {
            throw new NotFoundException(e.message);
        }
    }

    @Get(':id')
    public async getById(@Param() params: any, @Res() res: Response, @Req() req: Request){
        if(!params.id || params.id.trim().length === 0){
            throw new BadRequestException("Id is required");
        }
        const fileInfoResponse = await this.fileInfoHandler.executeAsync(new FileInfoCommand(params.id));
        return res.status(200).json(fileInfoResponse);
    }


    @Post('upload/:id')
    @UseInterceptors(CustomFileInterceptor('file'))
    @HttpCode(200)
    @UsePipes(FileTypeValidationPipe)
    async uploadFile(@Param() params: any , @UploadedFile() file: Express.Multer.File, @Req() res: Response){
        if(!params.id || params.id.trim().length === 0){
            throw new Error("Id is required");
        }

        return await this.fileUploadHandler.executeAsync(new FileUploadCommand(
            params.id,
            file.buffer
        ));
    }
}
