import { Global, Module } from '@nestjs/common';
import { DB_PROVIDER } from './database.constants';
import { WineDb } from './wine.db';
import { ConfigModule, ConfigService } from '@nestjs/config'; // Import ConfigService

@Global()
@Module({
    // You can optionally import ConfigModule here if you want to inject ConfigService
    // but since it's global, it's not strictly necessary. It does make the dependency explicit.
    imports: [ConfigModule],
    providers: [
        {
            provide: DB_PROVIDER,
            // useFactory is a function that NestJS will call
            // It can even inject other providers, like ConfigService
            useFactory: (configService: ConfigService) => {
                // Now, this code runs *during* the NestJS init phase.
                // The .env file has been loaded, and configService is available.
                console.log(`DATABASE_TYPE from ConfigService: ${configService.get('DATABASE_TYPE')}`);
                WineDb.tryMigrate();
                return WineDb.get();
            },
            // Tell NestJS to inject ConfigService into our factory function
            inject: [ConfigService],
        },
    ],
    exports: [DB_PROVIDER],
})
export class DatabaseModule {}