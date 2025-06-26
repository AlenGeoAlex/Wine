import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import {UserCommand} from "@features/user/cli/user.command";
import {ListUserCommand} from "@features/user/cli/list";
import {CreateUserCommand} from "@features/user/cli/create";
import {UpdateUserCommand} from "@features/user/cli/update";
import {DeleteUserCommand} from "@features/user/cli/delete";

@Module({
  providers: [
      UserService,
      UserCommand,
      ListUserCommand,
      CreateUserCommand,
      UpdateUserCommand,
      DeleteUserCommand,
  ],
  exports: [
      UserService,
  ],
  controllers: [
      UserController
  ],
})
export class UserModule {}
