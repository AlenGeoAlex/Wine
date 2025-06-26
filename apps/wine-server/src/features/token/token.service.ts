import {Injectable} from '@nestjs/common';
import {DatabaseService} from "@db/database";

@Injectable()
export class TokenService {

    constructor(
        private readonly databaseService : DatabaseService,
    ) {
    }

    public async getUserIdByToken(token: string) : Promise<{
        userId: string,
        expiresAt: Date | null,
    } | undefined> {
        const db = this.databaseService.getDb();
        let deviceToken = await db.selectFrom('deviceToken')
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
