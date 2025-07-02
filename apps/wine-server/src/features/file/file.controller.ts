import {
    Body,
    Controller,
    HttpCode,
    Logger,
    Param,
    Post,
    Req,
    Res,
    UploadedFile,
    UseInterceptors,
    UsePipes
} from '@nestjs/common';
import {Response} from 'express';
import {FileCreateHandler, FileCreateRequest, FileCreateResponse} from "@features/file/handlers/file-create-handler";
import {FileTypeValidationPipe} from "@/pipes/file-type-validation.pipe";
import {CustomFileInterceptor} from "@/interceptor/custom-file.interceptor";
import {FileUploadCommand, FileUploadHandler} from "@features/file/handlers/file-upload-handler";


@Controller('api/v1/file')
export class FileController {

    private readonly logger = new Logger(FileController.name);

    constructor(
        private readonly fileCreateHandler : FileCreateHandler,
        private readonly fileUploadHandler : FileUploadHandler,
    ) {
    }

    @Post()
    public async post(@Body() command: FileCreateRequest, @Res() res: Response){
        const fileUploadResponse = await this.fileCreateHandler.executeAsync(command);

        if(fileUploadResponse instanceof FileCreateResponse){
            return res.status(201).json(fileUploadResponse);
        }else {
            return res.status(fileUploadResponse.code).json(fileUploadResponse);
        }
    }

    // @All("upload/*")
    // public async uploadPost(@Req() req : Request, @Res() res : Response, @Query() id: string) {
    //     return await this.tusProvider.tus.handle(req, res)
    // }


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
