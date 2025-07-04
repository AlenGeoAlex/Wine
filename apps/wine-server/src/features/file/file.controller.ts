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
import {createReadStream} from "node:fs";


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
    public async get(@Param('id') id: string, @Res() res: Response, @Req() req: Request): Promise<void> {
        if (!id || id.trim().length === 0) {
            throw new BadRequestException("Id is required");
        }

        const fileSecret = req.headers['x-file-secret'] as string | undefined;
        const getResponse = await this.fileContentHandler.executeAsync(new FileContentCommand(id, fileSecret));

        if (getResponse.redirect) {
            return res.redirect(getResponse.redirect);
        }

        if (getResponse.filePath) {
            try {
                const fileStream = createReadStream(getResponse.filePath);
                res.setHeader('Content-Type', 'image/png');
                res.setHeader('Content-Disposition', `inline; filename="${id}.png"`);
                fileStream.pipe(res);
            } catch (e) {
                throw new NotFoundException(e.message);
            }
        } else {
            throw new NotFoundException();
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
