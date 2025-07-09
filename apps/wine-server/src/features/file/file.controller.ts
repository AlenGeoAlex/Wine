import {
    BadRequestException,
    Body,
    Controller,
    Delete,
    Get,
    HttpCode,
    Logger,
    NotFoundException,
    Param,
    Post,
    Query,
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
import {FileUploadCommand, FileUploadHandler, FileUploadResponse} from "@features/file/handlers/file-upload-handler";
import {FileContentCommand, FileContentHandler} from "@features/file/handlers/file-content-handler.service";
import {FileInfoCommand, FileInfoHandler, FileInfoResponse} from "@features/file/handlers/file-info-handler";
import {FileListHandler, FileListQuery, FileListResponse} from "@features/file/handlers/file-list-handler";
import {FileDeleteHandler} from "@features/file/handlers/file-delete-handler";
import {
    FilePreSignedUrlCommand,
    FilePreSignedUrlHandler
} from "@features/file/handlers/file-pre-signed-url-handler.service";

@Controller('api/v1/file')
export class FileController {

    private readonly logger = new Logger(FileController.name);

    constructor(
        private readonly fileCreateHandler : FileCreateHandler,
        private readonly fileUploadHandler : FileUploadHandler,
        private readonly fileContentHandler : FileContentHandler,
        private readonly fileInfoHandler: FileInfoHandler,
        private readonly fileListHandler : FileListHandler,
        private readonly fileDeleteHandler : FileDeleteHandler,
        private readonly filePresignedUrl: FilePreSignedUrlHandler
    ) {
    }

    /**
     * Handles HTTP POST requests for file creation.
     * Processes the provided request body for file creation, executes the file creation handler,
     * and sends the appropriate response based on the result.
     *
     * @param {FileCreateRequest} command - The file creation request payload.
     * @param {Response} res - The HTTP response object to send back the result.
     * @return {Promise<Response>} The HTTP response containing the result of the file creation operation.
     */
    @Post()
    public async post(@Body() command: FileCreateRequest, @Res() res: Response): Promise<Response>{
        this.logger.log(`File upload request: ${JSON.stringify(command)}`);
        const fileUploadResponse = await this.fileCreateHandler.executeAsync(command);
        this.logger.log(`File upload response: ${JSON.stringify(fileUploadResponse)}`);
        if(fileUploadResponse instanceof FileCreateResponse){
            return res.status(201).json(fileUploadResponse);
        }else {
            return res.status(fileUploadResponse.code).json(fileUploadResponse);
        }
    }

    /**
     * Handles the HTTP GET request to retrieve a list of files based on the provided query parameters.
     *
     * @param {FileListQuery} query - The query object containing the parameters for filtering the file list. The `userId` field is explicitly set to undefined within the method.
     * @return {Promise<FileListResponse>} A promise that resolves to the response containing the list of files.
     */
    @Get()
    public async list(@Query() query : FileListQuery) : Promise<FileListResponse>{
        query.userId = undefined;
        return await this.fileListHandler.executeAsync(query);
    }

    /**
     * Deletes a resource by its identifier.
     *
     * @param {string} id - The unique identifier of the resource to be deleted.
     * @return {Promise<void>} A promise that resolves when the resource is successfully deleted.
     * @throws {BadRequestException} If the provided id is invalid or empty.
     */
    @Delete(':id')
    @HttpCode(204)
    public async delete(@Param('id') id: string): Promise<void>{
        if (!id || id.trim().length === 0) {
            throw new BadRequestException("Id is required");
        }

        await this.fileDeleteHandler.executeAsync(id);
        return
    }

    /**
     * Handles file content retrieval based on the provided file ID and optional file secret.
     * Responds with the file content, redirects if necessary, or throws exceptions if the ID is invalid or the file is not found.
     *
     * @param {string} id - The unique identifier for the file. Must be a non-empty string.
     * @param {Response} res - The HTTP response object used to send file content or redirect.
     * @param {Request} req - The HTTP request object containing headers like `x-file-secret`.
     * @return {Promise<Response>} A promise resolving to the HTTP response.
     * @throws {BadRequestException} If the file ID is missing or empty.
     * @throws {NotFoundException} If the requested file is not found.
     */
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

        if (!getResponse.filePath) {
            throw new NotFoundException();
        }

        return res.sendFile(getResponse.filePath, {
            headers: {
                'Content-Type': getResponse.contentType,
            },
            acceptRanges: true
        });

        // try {
        //     const stat = statSync(getResponse.filePath);
        //     const fileSize = stat.size;
        //     const range = req.headers["range"];
        //
        //     if (range) {
        //         // Example: "bytes=0-"
        //         const parts = range.replace(/bytes=/, '').split('-');
        //         const start = parseInt(parts[0], 10);
        //         const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
        //
        //         if (start >= fileSize || isNaN(start)) {
        //             res.writeHead(416, {
        //                 'Content-Range': `bytes */${fileSize}`,
        //             });
        //             return res.end();
        //         }
        //
        //         const chunkSize = (end - start) + 1;
        //         const stream = createReadStream(getResponse.filePath, { start, end });
        //
        //         res.writeHead(206, {
        //             'Content-Range': `bytes ${start}-${end}/${fileSize}`,
        //             'Accept-Ranges': 'bytes',
        //             'Content-Length': chunkSize,
        //             'Content-Type': 'video/mp4',
        //         });
        //
        //         return stream.pipe(res);
        //     }
        //
        //     res.writeHead(200, {
        //         'Content-Length': fileSize,
        //         'Content-Type': getResponse.contentType,
        //     });
        //
        //     return createReadStream(getResponse.filePath).pipe(res);
        // } catch (e) {
        //     throw new NotFoundException(e.message);
        // }
    }

    /**
     * Fetches a file's information by its identifier.
     *
     * @param {Object} params - The route parameters.
     * @param {string} params.id - The identifier of the file.
     * @param {Response} res - The HTTP response object.
     * @param {Request} req - The HTTP request object.
     * @return {Promise<FileInfoResponse>} A promise that resolves with the file's information.
     * @throws {BadRequestException} If the id parameter is not provided or is empty.
     */
    @Get(':id')
    @HttpCode(200)
    public async getById(@Param() params: any, @Res() res: Response, @Req() req: Request): Promise<FileInfoResponse>{
        if(!params.id || params.id.trim().length === 0){
            throw new BadRequestException("Id is required");
        }
        return await this.fileInfoHandler.executeAsync(new FileInfoCommand(params.id));
    }

    /**
     * Handles file upload for a specific resource identified by ID.
     * This method validates the file type and uploads the file associated with the given ID.
     *
     * @param {Object} params - The request parameters containing the `id` of the resource.
     * @param {string} params.id - The unique identifier of the resource being uploaded.
     * @param {Express.Multer.File} file - The uploaded file object provided by the client.
     * @param {Response} res - The HTTP response object.
     * @return {Promise<FileUploadResponse>} - A promise that resolves with the response containing file upload details.
     */
    @Post(':id/content')
    @UseInterceptors(CustomFileInterceptor('file'))
    @HttpCode(200)
    @UsePipes(FileTypeValidationPipe)
    async uploadFile(@Param() params: any , @UploadedFile() file: Express.Multer.File, @Req() res: Response): Promise<FileUploadResponse>{
        if(!params.id || params.id.trim().length === 0){
            throw new Error("Id is required");
        }

        return await this.fileUploadHandler.executeAsync(new FileUploadCommand(
            params.id,
            file.buffer
        ));
    }

    @Post(":id/presigned-url")
    public async getPresignedUrl(@Param() params: any, @Body() body: FilePreSignedUrlCommand){
        if(!params.id || params.id.trim().length === 0){
            throw new Error("Id is required");
        }


    }
}
