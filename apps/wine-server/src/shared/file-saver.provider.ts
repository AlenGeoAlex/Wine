import {Injectable, InternalServerErrorException, Logger, NotFoundException} from '@nestjs/common';
import {ConfigService} from "@nestjs/config";
import {CONSTANTS} from "@common/constants";
import * as fs from 'fs/promises';
import * as path from 'path';

@Injectable()
export class FileSaverProvider {

    private readonly logger : Logger = new Logger(FileSaverProvider.name);

    constructor(
        private readonly configService: ConfigService,
    ) {
    }

    async uploadFile(dir: string, name: string, buffer: Buffer): Promise<string> {
        const rootPath = this.configService.get<string>(
            CONSTANTS.CONFIG_KEYS.STORAGE.FS.FS_FILE_PATH,
        );

        if (!rootPath) {
            this.logger.error('Storage path not configured');

            throw new Error('Storage path not configured');
        }

        try {
            const parentDirectory = path.join(rootPath, dir);
            const fullFilePath = path.join(parentDirectory, name);
            await fs.mkdir(parentDirectory, { recursive: true });
            await fs.writeFile(fullFilePath, buffer);
            return fullFilePath;
        } catch (err) {
            console.error('File save failed:', err);
            throw new Error('Failed to save file');
        }
    }

    async getFile(filePath: string): Promise<Buffer> {
        const rootPath = this.configService.get<string>(
            CONSTANTS.CONFIG_KEYS.STORAGE.FS.FS_FILE_PATH,
        );

        if (!rootPath) {
            this.logger.error('Storage path not configured');
            throw new Error('Storage path not configured');
        }

        const absolutePath = path.join(rootPath, filePath);

        try {
            return await fs.readFile(absolutePath);
        } catch (err: any) {
            if (err.code === 'ENOENT') {
                this.logger.error('File not found:', err);
                throw new NotFoundException('File not found');
            }
            this.logger.error('Error reading file:', err);
            throw new InternalServerErrorException('Failed to read file');
        }
    }
}
