import {Inject, Injectable} from '@nestjs/common';
import {DB_PROVIDER} from "../../db/database.constants";
import {Kysely} from "kysely";
import {IDatabase} from "common-models";
import {DeviceToken} from "common-models/dist/types/user.types";

@Injectable()
export class TokenService {

    constructor(
        @Inject(DB_PROVIDER) private readonly db : Kysely<IDatabase>
    ) {
    }

    public async getUserIdByToken(token: string) : Promise<{
        userId: string,
        expiresAt: Date | null,
    } | undefined> {
        let deviceToken = await this.db.selectFrom('deviceToken')
            .where('token', '=', token)
            .select(['userId', 'expiry'])
            .executeTakeFirst()

        if(!deviceToken)
            return undefined;

        return {
            userId: deviceToken.userId,
            expiresAt: deviceToken.expiry,
        };
    }
}
