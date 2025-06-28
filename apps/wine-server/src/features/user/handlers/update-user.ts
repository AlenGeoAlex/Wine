import { DatabaseService } from "@/db/database";
import {ICommandHandler, ICommandRequest, ICommandResponse, IErrorResponse} from "@common/utils";
import {UserService} from "@features/user/user.service";

export class UpdateUserCommand implements ICommandRequest<any> {
    id? : string
    email? : string
    name? : string
    disabled? : boolean


    constructor(id?: string, email?: string, name?: string, disabled?: boolean) {
        this.id = id;
        this.email = email;
        this.name = name;
        this.disabled = disabled;
    }
}

export class UpdateUserResponse implements ICommandResponse {

}

export class UpdateUserError implements IErrorResponse {
    code: number;
    message: string;
    meta?: Record<string, string>;

    constructor(code: number, message: string) {
        this.code = code;
        this.message = message;
    }
}

export class UpdateUserHandler implements ICommandHandler<UpdateUserCommand, UpdateUserResponse | UpdateUserError> {

    constructor(
        private readonly userService: UserService,
        private readonly databaseService: DatabaseService,
    ) {
    }

    async executeAsync(params: UpdateUserCommand): Promise<UpdateUserResponse | UpdateUserError> {

        if(!params.id && !params.email){
            return new UpdateUserError(
                400,
                "Id or email are required",
            );
        }

        if(!params.name && typeof params.disabled === "undefined")
        {
            return new UpdateUserError(
                400,
                "Name or disabled are required to update user",
            )
        }

        const transaction = await this.databaseService.transaction();
        try {



            const updateResponse = await this.userService.update(
                (params.id ?? params.email)!,
                {
                    id: (params.id ?? params.email)!,
                    name: params.name,
                    disabled: params.disabled
                },
                {
                    isIdentityAsEmail: typeof params.id === "undefined"
                },
                {
                    trx: transaction
                }
            )
            await transaction.commit().execute();

            if(!updateResponse){
                return new UpdateUserError(
                    404,
                    "User not found"
                );
            }

            return new UpdateUserResponse();
        }catch (e) {
            await transaction.rollback().execute();
            return new UpdateUserError(
                500,
                 "Failed to update user",
            );
        }
    }
}