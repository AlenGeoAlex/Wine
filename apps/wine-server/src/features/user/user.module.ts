import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import {ListUserCommandCli} from "@features/user/cli/list";
import {UpdateUserCommandCli} from "@features/user/cli/update";
import {SharedModule} from "@shared/shared.module";

@Module({
  providers: [
      UserService,
      ListUserCommandCli,
      UpdateUserCommandCli,
  ],
  exports: [
      UserService,
  ],
  imports: [
    SharedModule,
  ],
  controllers: [
      UserController
  ],
})
export class UserModule {}
