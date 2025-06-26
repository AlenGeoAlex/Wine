import { Global, Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import {DatabaseService} from "@db/database";

@Global()
@Module({
    imports: [ConfigModule],
    providers: [
        DatabaseService
    ],
    exports: [DatabaseService],
})
export class DatabaseModule {}