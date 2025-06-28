import {CommandRunner, Option, Command} from "nest-commander";
import { IsOptional } from "class-validator";
import {UserService} from "@features/user/user.service";
import {UpdateUserCommand, UpdateUserError, UpdateUserHandler} from "@features/user/handlers/update-user";
import {DatabaseService} from "@db/database";


@Command({ name: 'user:update', description: 'Update a user' })
export class UpdateUserCommandCli extends CommandRunner {

    constructor(
        private readonly userService: UserService,
        private readonly dataService: DatabaseService,
    ) {
        super();
    }

    async run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        const id = options?.id;
        const email = options?.email;
        if (!id && !email)
        {
            console.error("Id or email are required");
            return;
        }

        const name = options?.name as string | undefined;
        const disable = options?.disable as boolean | undefined;

        const updateResponse = await new UpdateUserHandler(this.userService, this.dataService)
            .executeAsync(new UpdateUserCommand(id, email, name, disable))



        if(updateResponse instanceof UpdateUserCommand){
            console.log("Updated the user")
        }else{
            const errorResponse = updateResponse as UpdateUserError;
            if(errorResponse.code === 500){
                console.error(`Failed to update user due to ${errorResponse.message}`)
                return Promise.resolve(undefined);
            }

            console.warn(errorResponse.message);
        }

        return Promise.resolve(undefined);
    }

    @IsOptional()
    @Option({
        flags: '-d, --disable <disable>',
        description: 'Disable the user',
    })
    parseDisable(val: string) : boolean {
        return ["true", "1", "yes"].includes(val.toLowerCase());
    }

    @Option({
        flags: '-n, --name <name>',
        description: 'Email of the user to update',
    })
    parseName(val: string) : string {
        return val;
    }

    @Option({
        flags: '-i, --id <id>',
        description: 'Id of the user to update',
    })
    parseId(val: string) : string {
        return val;
    }

    @Option({
        flags: '-e, --email <email>',
        description: 'Email of the user to update',
    })
    parseEmail(val: string) : string {
        return val;
    }



}