import {Command, CommandRunner, Option} from "nest-commander";
import {CreateUserCommand} from "./create";
import {UpdateUserCommand} from "./update";
import {DeleteUserCommand} from "./delete";
import {ListUserCommand} from "./list";

@Command({
    name: 'user',
    description: 'commands related to user management',
    subCommands: [ListUserCommand, CreateUserCommand, UpdateUserCommand, DeleteUserCommand],
})
export class UserCommand extends CommandRunner {
    run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        console.log(`[${passedParams}] ${passedParams}`);
        return Promise.resolve(undefined);
    }

}
