import {CommandRunner, SubCommand} from "nest-commander";
import {UserCreateCommandOptions} from "../dto/cli/UserCreateCommandOptions";
import {UserService} from "../user.service";

@SubCommand({ name: 'create', arguments: '[email] [name]' })
export class CreateUserCommand extends CommandRunner {

    constructor(
        private readonly userService: UserService
    ) {
        super();
    }

    async run(passedParams: string[], options?: UserCreateCommandOptions): Promise<void> {
        if(!options?.email)
            throw new Error("Email is required");

        if(!options?.name)
            throw new Error("Name is required");

        try {
            const id = await this.userService.create({
                id: '',
                email: options.email,
                name: options.name,
                createdAt: new Date()
            });

            console.log(`Created user with id ${id} with {email: ${options.email}, name: ${options.name}}`);
        }catch (e){
            console.error(e);
        }

        return Promise.resolve(undefined);
    }

}