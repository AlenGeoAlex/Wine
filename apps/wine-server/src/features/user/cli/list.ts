import {Command, CommandRunner, Option} from "nest-commander";

import {UserService} from "../user.service";
import {IsInt, IsOptional, Min} from "class-validator";
import {Transform} from "class-transformer";
import {ListUserCommand, ListUserHandler} from "@features/user/handlers/list-user";

@Command({
    name: 'user:list',
    description: "Lists out the user"
})
export class ListUserCommandCli extends CommandRunner {

    constructor(
        private readonly userService: UserService,
    ) {
        super();
    }

    async run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        console.log(options);
        const skip = options?.skip || 0;
        const take = options?.take || 1;
        const search = options?.query || undefined;

        const handler = new ListUserHandler(this.userService);

        const response = await handler.executeAsync(new ListUserCommand(search, skip, take))

        if(response.items.length > 0) {
            console.log(`Found ${response.items.length} users`);
            console.table(response.items);
        }else{
            console.warn("No users found...");
        }
        return Promise.resolve(undefined);
    }

    @IsOptional()
    @Transform(({ value }) => parseInt(value))
    @IsInt({ message: 'Skip must be a valid integer' })
    @Min(0, { message: 'Skip must be a positive integer' })
    @Option({
        flags: '-s, --skip <skip>',
        description: 'Skip the first <skip> users',
    })
    parseSkip(val: string) : number {
        return parseInt(val);
    }

    @IsOptional()
    @Transform(
        ({value}) => parseInt(value)
    )
    @IsInt({message: "Take must be a valid integer"})
    @Min(1,  {message: "Take must be a positive integer greater than 0"})
    @Option({
        flags: '-t, --take <take>',
        description: 'Take the users',
    })
    parseTake(val: string) : number {
        return parseInt(val);
    }

    @IsOptional()
    @Option({
        flags: '-q, --query <query>',
        description: 'Search for users by name or email',
    })
    parseQuery(val: string) : string {
        return val;
    }

}