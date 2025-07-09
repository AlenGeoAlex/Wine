import {Injectable, Logger, UnauthorizedException} from '@nestjs/common';
import {ICommandHandler} from "@common/utils";
import {FileService} from "@features/file/file.service";
import {ClsService} from "nestjs-cls";
import {CONSTANTS} from "@common/constants";
import {DatabaseService} from "@db/database";
import {EventEmitter2} from "@nestjs/event-emitter";
import {FileDeletedEvent} from "@features/file/events.file";


@Injectable()
export class FileDeleteHandler  implements ICommandHandler<string, boolean>{

    private readonly logger = new Logger(FileDeleteHandler.name);

    constructor(
        private readonly fileService : FileService,
        private readonly clsService: ClsService,
        private readonly databaseService : DatabaseService,
        private readonly eventEmitter: EventEmitter2,
    ) {
    }

    async executeAsync(params: string): Promise<boolean> {
        const userId = this.clsService.get(CONSTANTS.MIDDLEWARE_KEYS.API_KEY_USER);
        if(!userId)
            throw new UnauthorizedException("Unknown user");

        const file = await this.fileService.getUpload(params);
        if(!file)
            return false;

        if(file.userId !== userId) //TODO add later to override this from CLI
            throw new UnauthorizedException("User is not authorized to delete this file");

        const transaction = await this.databaseService.transaction();
        try {
            await this.fileService.deleteUpload(params, userId, {
                trx: transaction
            })

            await transaction.commit().execute();
            this.eventEmitter.emit('file.deleted', new FileDeletedEvent(
                file.id,
                FileDeleteHandler.name,
            ));
            return true;
        }catch (e) {
            this.logger.error(e);
            return false;
        }
    }
}
