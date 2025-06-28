import { Module } from '@nestjs/common';
import {UserModule} from "@features/user/user.module";
import {TokenModule} from "@features/token/token.module";
import { UserCreationHandler } from './user-creation-handler';
import {CreateUserCommandCli} from "@features/user-creation/user-creation-cli";

@Module({
    imports: [
        UserModule,
        TokenModule
    ],
    providers: [
        UserCreationHandler,
        CreateUserCommandCli
    ]
})
export class UserCreationModule {}
