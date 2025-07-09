import {Injectable, Logger} from '@nestjs/common';
import {ICommandHandler, ICommandRequest, ICommandResponse, IErrorResponse} from "@common/utils";
import {UserService} from "@features/user/user.service";
import {DatabaseService} from "@db/database";
import {TokenService} from "@features/token/token.service";
import {ulid} from "ulid";

@Injectable()
export class UserCreationHandler implements ICommandHandler<UserCreationCommand, UserCreationCommandResponse | UserCreationError>{

    private readonly logger = new Logger(UserCreationHandler.name)

    constructor(
        private readonly userService: UserService,
        private readonly databaseService: DatabaseService,
        private readonly tokenService: TokenService,
    ) {
    }

    async executeAsync(params: UserCreationCommand): Promise<UserCreationCommandResponse | UserCreationError> {
        const transaction = await this.databaseService.transaction();
        try {

            const user = await this.userService.create({
                id: ulid(),
                email: params.email,
                disabled: params.disabled,
                createdAt: new Date(),
                name: params.name ?? "Unnamed User",
            }, {
                trx: transaction
            })


            const token = params.token ?? `${crypto.randomUUID().replace(/-/g, "").toUpperCase()}`;
            await this.tokenService.create({
                id: '',
                disabled: false,
                token: token,
                createdAt: new Date(),
                userId: user
            }, {
                trx: transaction
            })

            await transaction.commit().execute();
            return new UserCreationCommandResponse(user, token);
        }catch (e) {
            await transaction.rollback().execute();
            this.logger.error(e);

            if(e instanceof Error && e.message.toLowerCase().includes("unique")){
                return new UserCreationError(
                    409,
                    "User with email already exists",
                );
            }

            return new UserCreationError(
                500,
                 "Failed to create user",
            );
        }
    }
}


export class UserCreationCommand implements ICommandRequest<UserCreationCommandResponse> {
    private readonly _email: string
    private readonly _name?: string
    private readonly _disabled: boolean
    private readonly _token?: string

    constructor(email: string, name?: string, disabled: boolean | undefined = true, token?: string) {
        this._email = email;
        this._name = name;
        this._disabled = disabled;
        this._token = token;
    }


    get email(): string {
        return this._email;
    }

    get name(): string | undefined {
        return this._name;
    }

    get disabled(): boolean {
        return this._disabled;
    }

    get token(): string | undefined {
        return this._token;
    }
}

export class UserCreationCommandResponse implements ICommandResponse {
    private readonly _id: string
    private readonly _token: string

    constructor(id: string, token: string) {
        this._id = id;
        this._token = token;
    }

    get id(): string {
        return this._id;
    }

    get token(): string {
        return this._token;
    }
}

export class UserCreationError implements IErrorResponse {
    code: number;
    message: string;
    meta?: Record<string, string>;


    constructor(code: number, message: string) {
        this.code = code;
        this.message = message;
    }
}