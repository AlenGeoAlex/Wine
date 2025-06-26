import { Injectable } from '@nestjs/common';
import {DatabaseService} from "@db/database";
import {UserService} from "@features/user/user.service";
import {TokenService} from "@features/token/token.service";

@Injectable()
export class UserTokenService {

    constructor(
        private readonly databaseService : DatabaseService,
        private readonly userService : UserService,
        private readonly tokenService : TokenService,
    ) {
    }

    public async deleteTokensOfUser(userId: string) : Promise<void> {
        await this.tokenService.deleteTokensOfUser(userId);
    }

}
