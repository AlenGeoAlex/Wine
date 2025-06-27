import {Command, CommandRunner, Option, SubCommand} from "nest-commander";
import {IsOptional} from "class-validator";
import {
    UserCreationCommand,
    UserCreationCommandResponse, UserCreationError,
    UserCreationHandler
} from "@features/user-creation/user-creation-handler";

@Command({
    name: "user:create",
    arguments: "[email] [name] <token>",
    description: "Create a new user",
})
export class CreateUserCommandCli extends CommandRunner {

    constructor(
        private readonly userCreationHandler : UserCreationHandler
    ) {
        super();
    }

    async run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        if(!options?.email){
            console.error("Email is required");
            return;
        }

        const creationResponse = await this.userCreationHandler.executeAsync(new UserCreationCommand(options.email, options.name, false));
        if(creationResponse instanceof UserCreationCommandResponse){
            console.log(`Created user with id ${creationResponse.id}`);
        }else{
            const userError = creationResponse as UserCreationError;
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

    @IsOptional()
    @Option({
        flags: '-t, --token <token>',
        description: 'Token of the user',
    })
    parseToken(val: string) : string {
        return val;
    }

}