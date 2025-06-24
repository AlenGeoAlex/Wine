import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import {UserCommand} from "./cli/user.command";
import {ListUserCommand} from "./cli/list";
import { UpdateUserCommand } from './cli/update';
import {CreateUserCommand} from "./cli/create";
import {DeleteUserCommand} from "./cli/delete";

const commandProviders = [
    UserCommand,
    ListUserCommand,
    CreateUserCommand,
    UpdateUserCommand,
    DeleteUserCommand,
];

@Module({
  providers: [
      UserService,
      ...commandProviders,
  ],
  exports: [
      UserService,
      ...commandProviders,
  ],
  controllers: [
      UserController
  ],
})
export class UserModule {}
