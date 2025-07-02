import { Global, Module} from '@nestjs/common';
import { FileSaverProvider } from './file-saver.provider';

@Global()
@Module({
    imports: [
    ],
    providers: [
      FileSaverProvider,
    ],
    exports: [
      FileSaverProvider
    ]
})
export class SharedModule {}
