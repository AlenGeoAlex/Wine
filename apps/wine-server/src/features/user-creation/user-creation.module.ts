import { Module } from '@nestjs/common';
import {UserModule} from "@features/user/user.module";
import {TokenModule} from "@features/token/token.module";
import { UserCreationHandler } from './user-creation-handler';

@Module({
    imports: [
        UserModule,
        TokenModule
    ],
    providers: [UserCreationHandler]
})
export class UserCreationModule {}
