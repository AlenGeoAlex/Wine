import { Global, Module} from '@nestjs/common';
import { FileSaverProvider } from './file-saver.provider';
import { CryptoService } from './crypto.service';
import { S3Service } from './s3.service';

@Global()
@Module({
    imports: [
    ],
    providers: [
      FileSaverProvider,
      CryptoService,
      S3Service,
    ],
    exports: [
        FileSaverProvider,
        CryptoService,
        S3Service,
    ]
})
export class SharedModule {}
