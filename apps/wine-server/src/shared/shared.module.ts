import { Module } from '@nestjs/common';
import {TusProvider} from "./tus.provider";

@Module({
    providers: [
        TusProvider
    ],
    exports: [
        TusProvider
    ]
})
export class SharedModule {}
