import {MiddlewareConsumer, Module, NestModule} from '@nestjs/common';
import {AppController} from "@features/app/app.controller";
import {ConfigModule} from "@nestjs/config";
import { DatabaseModule } from '@db/database.module';
import { UserModule } from '@features/user/user.module';
import {ClsModule} from "nestjs-cls";
import {TokenModule} from "@features/token/token.module";
import {FileModule} from "@features/file/file.module";
import {DIServiceProvider} from "@common/di.service.provider";
import {SharedModule} from "@shared/shared.module";
import {ServeStaticModule} from "@nestjs/serve-static";
import { join } from 'path';
import {EventEmitterModule} from "@nestjs/event-emitter";
import { UserCreationModule } from '@features/user-creation/user-creation.module';
import { UserDeletionModule } from '@features/user-deletion/user-deletion.module';
import {ApiUserMiddlewareMiddleware} from "@/middleware/api-user-middleware.middleware";
import { StaticController } from './static.controller';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
        }),
        ClsModule.forRoot({
            global: true,
            middleware: {
                mount: true,
                setup: (cls, req) => {
                    cls.set('apiKey', req.headers["x-api-key"])
                }
            }
        }),
        ServeStaticModule.forRoot({
            rootPath: join(__dirname, '..', 'static'),
            exclude: ['/index.html']
        }),
        EventEmitterModule.forRoot({
            global: true,
            verboseMemoryLeak: true,
            ignoreErrors: true,
        }),
        DatabaseModule,
        UserModule,
        TokenModule,
        FileModule,
        SharedModule,
        UserCreationModule,
        UserDeletionModule,
    ],
    controllers: [AppController, StaticController],
    providers: [
        DIServiceProvider,
    ],
})
export class AppModule implements NestModule {
    configure(consumer : MiddlewareConsumer) {
        consumer
            .apply(ApiUserMiddlewareMiddleware)
            .forRoutes('api/v1/file')
    }
}
