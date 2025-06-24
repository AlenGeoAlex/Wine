import {CommandRunner, SubCommand} from "nest-commander";

import {UserService} from "../user.service";
import {UserListCommandOptions} from "../dto/cli/UserListCommandOptions";

@SubCommand({ name: 'list', arguments: '' })
export class ListUserCommand extends CommandRunner {

    constructor(
        private readonly userService: UserService,
    ) {
        super();
    }

    async run(passedParams: string[], options?: UserListCommandOptions): Promise<void> {
        const skip = options?.skip || 0;
        const take = options?.take || 1;
        const search = options?.search || undefined;

        const users = await this.userService.list({
            pagination: {
                skip,
                take
            },
            search: {
                searchTerm: search,
            }
        })

        if(users.length > 0) {
            console.log(`Found ${users.length} users`);
            console.table(users);
        }else{
            console.warn("No users found...");
        }
        return Promise.resolve(undefined);
    }

}