import {CommandRunner, Option, SubCommand} from "nest-commander";

import {UserService} from "../user.service";
import {IsInt, IsOptional, Min} from "class-validator";
import {Transform} from "class-transformer";

@SubCommand({
    name: 'list',
})
export class ListUserCommand extends CommandRunner {

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