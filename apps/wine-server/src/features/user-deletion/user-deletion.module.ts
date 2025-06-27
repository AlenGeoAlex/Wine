import { Module } from '@nestjs/common';
import { UserDeletionHandler } from './user-deletion-handler';
import { UserDeletionCli } from './user-deletion-cli';
import {UserModule} from "@features/user/user.module";
import {TokenModule} from "@features/token/token.module";

@Module({
  imports: [UserModule, TokenModule],
  providers: [UserDeletionHandler, UserDeletionCli]
})
export class UserDeletionModule {}
