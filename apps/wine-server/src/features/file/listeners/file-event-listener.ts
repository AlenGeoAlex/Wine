import {Injectable, Logger} from '@nestjs/common';
import {FileService} from '../file.service';
import {ConfigService} from "@nestjs/config";
import {OnEvent} from "@nestjs/event-emitter";
import {namespaceOf} from "@common/events";
import {FileCreatedEvent, FileDeletedEvent} from "@features/file/events.file";
import {CONSTANTS} from "@common/constants";
import {StorageProvider} from "@common/enums";
import {FileSaverProvider} from "@shared/file-saver.provider";
import {DatabaseService} from "@db/database";

@Injectable()
export class FileEventListener {

    private readonly logger : Logger = new Logger(FileEventListener.name);

    constructor(
        private readonly fileService : FileService,
        private readonly configService: ConfigService,
        private readonly fileSaverProvider: FileSaverProvider,
        private readonly databaseService: DatabaseService,
    ) {
    }

    @OnEvent(namespaceOf("deleted", "file"), {
        async: true
    })
    private async onFileDeleted(event: FileDeletedEvent) {
        this.logger.log(`Received event for file deleted with id=[${event.eventId}] for file [${event.fileId}]`)
        const fileUpload = await this.fileService.getUpload(event.fileId, {includeDeleted: true});
        if(!fileUpload)
        {
            this.logger.warn(`File with id ${event.fileId} not found for deletion, skipping it`);
            return;
        }

        const provider = (this.configService.get(CONSTANTS.CONFIG_KEYS.STORAGE.STORAGE_PROVIDER) ?? StorageProvider.FS) as StorageProvider
        if(provider === StorageProvider.FS){
            const fileDeletionResponse = await this.fileSaverProvider.deleteFile(fileUpload.fileKey);
            if(!fileDeletionResponse)
            {
                this.logger.warn(`Failed to delete file with id ${event.fileId} from storage, the file won't be deleted from the database`);
                return;
            }
        }

        const trx = await this.databaseService.transaction();
        try {
            await this.fileService.hardDeleteAsync(fileUpload.id, {
                trx: trx,
            })
            this.logger.log(`File with id ${event.fileId} deleted from database`);
            await trx.commit().execute();
        }catch (e) {
            await trx.rollback().execute();
            this.logger.error(e);
        }
    }

    @OnEvent(namespaceOf("created", "file"), {
        async: true,
    })
    private async onFileCreated(event: FileCreatedEvent) {
        this.logger.log(`Received event for file created with id=[${event.eventId}] for file [${event.fileId}]`)

    }

}
