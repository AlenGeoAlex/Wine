import {NestFactory} from '@nestjs/core';
import {AppModule} from './app.module';
import {ConsoleLogger, Logger, ValidationPipe, VersioningType} from "@nestjs/common";
import helmet from "helmet";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: new ConsoleLogger({
      json: true,
    })
  });
  app.enableVersioning({
    type: VersioningType.URI
  })

  app.useGlobalPipes(new ValidationPipe());
  app.use(helmet());
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
