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
  app.use(
      helmet({
        contentSecurityPolicy: {
          directives: {
            ...helmet.contentSecurityPolicy.getDefaultDirectives(),
            "script-src": ["'self'", "https://releases.transloadit.com"], // <-- 1. Allow 'self' AND the Uppy CDN
            // If you MUST use the inline script from the previous answer, add 'unsafe-inline'
            // "script-src-elem": ["'self'", "https://releases.transloadit.com", "'unsafe-inline'"],
          },
        },
      }),
  );

  // Make sure CORS is enabled
  app.enableCors();
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
