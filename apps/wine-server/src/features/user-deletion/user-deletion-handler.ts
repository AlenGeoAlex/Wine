import { Injectable } from '@nestjs/common';
import {ICommandHandler, ICommandRequest, ICommandResponse} from "@common/utils";
import {UserService} from "@features/user/user.service";
import {DatabaseService} from "@db/database";
import {TokenService} from "@features/token/token.service";

@Injectable()
export class UserDeletionHandler implements ICommandHandler<UserDeletionCommand, UserDeletionResponse>{
    constructor(
        private readonly userService : UserService,
        private readonly databaseService : DatabaseService,
        private readonly tokenService : TokenService,
    ) {
    }

    async executeAsync(params: UserDeletionCommand): Promise<UserDeletionResponse> {

        if(!params.id && !params.email){
            return new UserDeletionError(
                400,
                "Id or email are required",
            );
        }

        let id = params.id;
        if(!id){
            const user = await this.userService
                .findByEmail(params.email!);

            if(!user){
                return new UserDeletionError(
                    404,
                    "User not found",
                );
            }

            id = user.id;
            console.log(`Found user with id ${id} with {email: ${user.email}, name: ${user.name}}`);
        }

        const transaction = await this.databaseService.transaction();
        try {

            await this.tokenService.deleteTokensOfUser(id);
            await this.userService.deleteUser(id);
            await transaction.commit().execute();
            return new UserDeletionResponse();
        }catch (e){
            await transaction.rollback().execute();
            return new UserDeletionError(
                500,
                "Failed to delete user",
            );
        }
    }
}

export class UserDeletionCommand implements ICommandRequest<UserDeletionResponse>{
    id?: string;
    email?: string;

    constructor(id?: string, email?: string) {
        this.id = id;
        this.email = email;
    }
}
export class UserDeletionResponse implements ICommandResponse{

}

export class UserDeletionError implements ICommandResponse{
    code: number;
    message: string;
    meta?: Record<string, string>;


    constructor(code: number, message: string) {
        this.code = code;
        this.message = message;
    }
}