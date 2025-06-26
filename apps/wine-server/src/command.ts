import {CommandFactory} from "nest-commander";
import { AppModule } from "./app.module";

async function bootstrap() {
    await CommandFactory.run(AppModule, {
        usePlugins: true, // This enables plugins like the built-in ValidationPipe
        logger: ['log']
    });
}

bootstrap();
