import {CommandRunner, Option, SubCommand} from "nest-commander";
import {UserCreateCommandOptions} from "../dto/cli/UserCreateCommandOptions";
import {UserService} from "../user.service";

@SubCommand({ name: 'create', arguments: '[email] [name]' })
export class CreateUserCommand extends CommandRunner {

    constructor(
        private readonly userService: UserService
    ) {
        super();
    }

    async run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        if(!options?.email)
            throw new Error("Email is required");

        try {
            const id = await this.userService.create({
                id: '',
                email: options.email,
                name: options.name ?? "Unnamed User",
                createdAt: new Date()
            });

            console.log(`Created user with id ${id} with {email: ${options.email}, name: ${options.name}}`);
        }catch (e){
            console.error(e);
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