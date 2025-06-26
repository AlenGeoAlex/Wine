import {Command, CommandRunner, Option} from "nest-commander";
import {CreateUserCommandCli} from "./create";
import {UpdateUserCommandCli} from "./update";
import {DeleteUserCommandCli} from "./delete";
import {ListUserCommandCli} from "./list";

@Command({
    name: 'user',
    description: 'commands related to user management',
    subCommands: [ListUserCommandCli, CreateUserCommandCli, UpdateUserCommandCli, DeleteUserCommandCli],
})
export class UserCommand extends CommandRunner {
    run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        return Promise.resolve(undefined);
    }

}
