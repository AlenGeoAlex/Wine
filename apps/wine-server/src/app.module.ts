import { Module } from '@nestjs/common';
import {AppController} from "@features/app/app.controller";
import {ConfigModule} from "@nestjs/config";
import { DatabaseModule } from '@db/database.module';
import { UserModule } from '@features/user/user.module';
import {ClsModule} from "nestjs-cls";
import {TokenModule} from "@features/token/token.module";
import {FileModule} from "@features/file/file.module";
import {DIServiceProvider} from "@common/di.service.provider";
import {SharedModule} from "@shared/shared.module";

@Module({
  imports: [
      ConfigModule.forRoot({
        isGlobal: true,
      }),
      ClsModule.forRoot({
          middleware: {
              mount: true,
              setup: (cls, req) => {
                  cls.set('apiKey', req.headers["x-api-key"])
              }
          }
      }),
      DatabaseModule,
      UserModule,
      TokenModule,
      FileModule,
      SharedModule,
  ],
  controllers: [AppController],
  providers: [
      DIServiceProvider
  ],
})
export class AppModule {}
