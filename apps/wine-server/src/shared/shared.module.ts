import {forwardRef, Global, Module} from '@nestjs/common';
import {TusProvider} from "./tus.provider";
import {FileModule} from "@features/file/file.module";
import { FileSaverProvider } from './file-saver.provider';

@Global()
@Module({
    imports: [
        forwardRef(() => FileModule),
    ],
    providers: [
      TusProvider,
      FileSaverProvider,
    ],
    exports: [
      TusProvider,
    ]
})
export class SharedModule {}
