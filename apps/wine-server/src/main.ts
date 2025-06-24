import {NestFactory} from '@nestjs/core';
import {AppModule} from './app.module';
import {IDatabase} from "common-models";
import {Kysely} from "kysely";
import {DB_PROVIDER} from "./db/database.constants";
import {WineDb} from "./db/wine.db";
import {ConsoleLogger, Logger, ValidationPipe, VersioningType} from "@nestjs/common";
import helmet from "helmet";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: new ConsoleLogger({
      json: true,
    })
  });

  const logger = new Logger("me.alenalex.wine.bootstrap");
  const dbInstance = app.get<Kysely<IDatabase>>(DB_PROVIDER);

  if(!dbInstance){
    throw new Error("Database instance not found");
  }

  if (!await WineDb.tryMigrate()) {
      throw new Error("Failed to migrate database");
  }

  logger.log("Database migration has been completed")
  app.enableVersioning({
    type: VersioningType.URI
  })

  app.useGlobalPipes(new ValidationPipe());
  app.use(helmet());
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
