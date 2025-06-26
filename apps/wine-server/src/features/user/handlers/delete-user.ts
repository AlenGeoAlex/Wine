import {ICommandHandler, ICommandRequest, ICommandResponse} from "@common/utils";
import {UserService} from "@features/user/user.service";
import {UserTokenService} from "@shared/user-token.service";
import {DatabaseService} from "@db/database";

export class DeleteUserCommand implements ICommandRequest<DeleteUserResponse>{
    id?: string;
    email?: string;

    constructor(id?: string, email?: string) {
        this.id = id;
        this.email = email;
    }
}
export class DeleteUserResponse implements ICommandResponse{

}

export class DeleteUserError implements ICommandResponse{
    code: number;
    message: string;
    meta?: Record<string, string>;


    constructor(code: number, message: string) {
        this.code = code;
        this.message = message;
    }
}

export class DeleteUserHandler implements ICommandHandler<DeleteUserCommand, DeleteUserResponse>{

    constructor(
        private readonly userService : UserService,
        private readonly databaseService : DatabaseService,
        private readonly userTokenService : UserTokenService,
    ) {
    }

    async executeAsync(params: DeleteUserCommand): Promise<DeleteUserResponse> {

        if(!params.id && !params.email){
            return new DeleteUserError(
                400,
                "Id or email are required",
            );
        }

        let id = params.id;
        if(!id){
            const user = await this.userService
                .findByEmail(params.email!);

            if(!user){
                return new DeleteUserError(
                    404,
                    "User not found",
                );
            }

            id = user.id;
            console.log(`Found user with id ${id} with {email: ${user.email}, name: ${user.name}}`);
        }

        const transaction = await this.databaseService.transaction();
        try {

            await this.userTokenService.deleteTokensOfUser(id);
            await this.userService.deleteUser(id);
            await transaction.commit().execute();
            return new DeleteUserResponse();
        }catch (e){
            transaction.rollback();
            return new DeleteUserError(
                500,
                "Failed to delete user",
            );
        }
    }



}