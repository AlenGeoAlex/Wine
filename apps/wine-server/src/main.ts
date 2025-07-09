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

  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
    transformOptions: {
      enableImplicitConversion: true
    },
    validationError: {
      target: false,
      value: false
    }
  }));
  app.use(
      helmet.contentSecurityPolicy({
        directives: {
          defaultSrc: ["'self'"],
          scriptSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          imgSrc: ["*", "data:", "blob:"],
          mediaSrc: ["*", "data:", "blob:"],
        },
      })
  );
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
