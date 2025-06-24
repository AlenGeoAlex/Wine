import {Injectable, Logger} from '@nestjs/common';
import {Server} from "@tus/server";
import {FileStore} from "@tus/file-store";

@Injectable()
export class TusProvider {

    private readonly logger = new Logger(TusProvider.name);
    private readonly tusServer : Server;

    constructor() {
        this.logger.log('TusProvider initialized');
        this.tusServer = new Server({
            path: '/Users/alenalex/Work/Files/',
            datastore: new FileStore({
                directory: '/Users/alenalex/Work/Files/'
            }),
        })
    }

    public get tus() : Server {
        return this.tusServer;
    }

}
