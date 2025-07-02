import {Controller, Get, Logger, NotFoundException, Param, Req, Res} from '@nestjs/common';
import { Request, Response } from 'express';
import * as fs from 'fs';
import { join } from 'path';
import * as cheerio from 'cheerio';
import {ConfigService} from "@nestjs/config";
import {CONSTANTS} from "@common/constants";

@Controller()
export class StaticController {

    private readonly logger : Logger = new Logger(StaticController.name);
    private imageView : string | undefined;
    private notFoundHtml : string | undefined;

    constructor(
        private readonly configService: ConfigService,
    ) {
        this.loadHtmlFile();
    }

    private loadHtmlFile(){
        this.logger.log("Loading html file");
        try {
            const htmlPath = join(__dirname, '..', 'static', 'index.html');
            this.logger.log(`Loading html file from ${htmlPath}`);
            this.imageView = fs.readFileSync(htmlPath, 'utf-8');
            this.logger.log("Html file loaded");
        }catch (e){
            this.logger.error("Failed to load html file");
            this.logger.error(e);
        }

        try {
            const htmlPath = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.GENERAL.NOT_FOUND_HTML) ?? join(__dirname, '..', 'static', '404.html');
            this.logger.log(`Loading html file from ${htmlPath}`);
            this.notFoundHtml = fs.readFileSync(htmlPath, 'utf-8');
            this.logger.log("Not found Html file loaded");
        }catch (e){
            this.logger.error("Failed to load html file");
            this.logger.error(e);
        }
    }

    @Get('/:id')
    async serveApp(@Req() req: Request, @Param() params: any, @Res() res: Response) {
        const url = req.url;
        if(!params.id)
            throw new NotFoundException();

        const ogImageUrl = `${req.protocol}://${req.host}/api/v1/og-image?id=${encodeURIComponent(
            params.id,
        )}`;

        if(!this.imageView)
            throw new NotFoundException();

        const $ = cheerio.load(this.imageView);
        // $('meta[property="og:title"]').attr('content', pageData.title);
        // $('meta[name="description"]').attr('content', pageData.description);
        // $('meta[property="og:description"]').attr('content', pageData.description);
        $('meta[property="og:image"]').attr('content', ogImageUrl);

        // 5. Send the modified HTML
        res.send($.html());
    }

    @Get()
    async serve404(@Res() res: Response){
        res.send(this.notFoundHtml ?? "Not found");
    }

}
