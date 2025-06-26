import { Module } from '@nestjs/common';
import {TusProvider} from "./tus.provider";
import { UserTokenService } from './user-token.service';

@Module({
    providers: [
        TusProvider,
        UserTokenService
    ],
    exports: [
        TusProvider
    ]
})
export class SharedModule {}
