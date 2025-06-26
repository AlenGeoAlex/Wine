import {CommandRunner, SubCommand, Option} from "nest-commander";
import {UserService} from "@features/user/user.service";
import {UserTokenService} from "@shared/user-token.service";
import {DatabaseService} from "@db/database";

@SubCommand({ name: 'delete', arguments: '[phooey]' })
export class DeleteUserCommandCli extends CommandRunner {

    constructor(
        private readonly userService: UserService,
        private readonly userTokenService: UserTokenService,
        private readonly databaseService : DatabaseService,
    ) {
        super();
    }

    async run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        let id = options?.id;
        const email = options?.email;

        if(!id && !email){
            console.error("Id or email are required");
            return;
        }



        const trx = await this.databaseService.transaction();
        try {

            trx.commit();
        }catch (e) {
            trx.rollback();

        }

        return Promise.resolve(undefined);
    }

    @Option({
        flags: '-i, --id <id>',
        description: 'Id of the user to delete',
    })
    parseId(val: string) : string {
        return val;
    }

    @Option({
        flags: '-e, --email <email>',
        description: 'Email of the user to delete',
    })
    parseEmail(val: string) : string {
        return val;
    }

}