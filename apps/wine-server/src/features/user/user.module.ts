import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import {UserCommand} from "@features/user/cli/user.command";
import {ListUserCommandCli} from "@features/user/cli/list";
import {CreateUserCommandCli} from "@features/user/cli/create";
import {UpdateUserCommandCli} from "@features/user/cli/update";
import {DeleteUserCommandCli} from "@features/user/cli/delete";

@Module({
  providers: [
      UserService,
      UserCommand,
      ListUserCommandCli,
      CreateUserCommandCli,
      UpdateUserCommandCli,
      DeleteUserCommandCli,
  ],
  exports: [
      UserService,
  ],
  controllers: [
      UserController
  ],
})
export class UserModule {}
