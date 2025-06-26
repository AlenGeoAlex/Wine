import {ICommandHandler, ICommandRequest, ICommandResponse, IErrorResponse} from "@common/utils";
import {UserService} from "@features/user/user.service";
import {DatabaseService} from "@db/database";
import {Logger} from "@nestjs/common";
import {ulid} from "ulid";

export class CreateUserCommand implements ICommandRequest<CreateUserCommandResponse | CreateUserError> {
    private readonly _email: string
    private readonly _name?: string
    private readonly _disabled: boolean

    constructor(email: string, name?: string, disabled: boolean | undefined = true) {
        this._email = email;
        this._name = name;
        this._disabled = disabled;
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
}

export class CreateUserCommandResponse implements ICommandResponse {
    private readonly _id: string

    constructor(id: string) {
        this._id = id;
    }

    get id(): string {
        return this._id;
    }
}

export class CreateUserError implements IErrorResponse {
    code: number;
    message: string;
    meta?: Record<string, string>;

}

export class CreateUserCommandHandler implements ICommandHandler<CreateUserCommand, CreateUserCommandResponse | CreateUserError>{

    private readonly logger = new Logger(CreateUserCommandHandler.name)

    constructor(
        private readonly userService: UserService,
        private readonly databaseService: DatabaseService,
    ) {
    }

    async executeAsync(params: CreateUserCommand): Promise<CreateUserCommandResponse | CreateUserError> {
        const transaction = await this.databaseService.transaction();
        try {
            const user = await this.userService.create({
                id: ulid(),
                email: params.email,
                disabled: params.disabled,
                createdAt: new Date(),
                name: params.name ?? "Unnamed User",
            })
            await transaction.commit().execute();
            return new CreateUserCommandResponse(user);
        }catch (e) {
            transaction.rollback();
            this.logger.error(e);

            if(e instanceof Error && e.message.toLowerCase().includes("unique")){
                return {
                    code: 409,
                    message: "User with email already exists",
                }
            }

            return {
                code: 500,
                message: "Failed to create user",
            }
        }
    }





}