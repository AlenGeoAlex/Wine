import {CommandRunner, Option, SubCommand} from "nest-commander";
import {UserCreateCommandOptions} from "../dto/cli/UserCreateCommandOptions";
import {UserService} from "../user.service";
import {
    CreateUserCommand,
    CreateUserCommandHandler,
    CreateUserCommandResponse, CreateUserError
} from "@features/user/handlers/create-user";
import {DatabaseService} from "@db/database";

@SubCommand({ name: 'create', arguments: '[email] [name]' })
export class CreateUserCommandCli extends CommandRunner {

    constructor(
        private readonly userService: UserService,
        private readonly databaseService : DatabaseService,
    ) {
        super();
    }

    async run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        if(!options?.email){
            console.error("Email is required");
            return;
        }

        const createUserCommandHandler = new CreateUserCommandHandler(
            this.userService,
            this.databaseService
        );

        const creationResponse = await createUserCommandHandler.executeAsync(new CreateUserCommand(options.email, options.name, false));
        if(creationResponse instanceof CreateUserCommandResponse){
            console.log(`Created user with id ${creationResponse.id}`);
        }else{
            const userError = creationResponse as CreateUserError;
            console.error(`Failed to create user [statusCode=${userError.code}] due to ${userError.message}`)
        }
        
        return Promise.resolve(undefined);
    }

    @Option({
        flags: '-e, --email <email>',
        description: 'Email of the user to create',
    })
    parseEmail(val: string) : string {
        return val;
    }

    @Option({
        flags: '-n, --name <name>',
        description: 'Name of the user to create',
    })
    parseName(val: string) : string {
        return val;
    }

}