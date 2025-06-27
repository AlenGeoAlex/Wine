import {Injectable} from '@nestjs/common';
import {DatabaseService} from "@db/database";
import {NewDeviceToken} from "common-models/dist/types/user.types";
import {ulid} from "ulid";

@Injectable()
export class TokenService {

    constructor(
        private readonly databaseService : DatabaseService,
    ) {
    }

    public async create(token: NewDeviceToken, options? : {}): Promise<string> {
        const db = this.databaseService.getDb();
        const id = ulid();
        let result = await db.insertInto('deviceToken')
            .values({
                id: id,
                token: token.token,
                createdAt: token.createdAt,
                disabled: this.databaseService.parseBoolean(false),
                userId: token.userId,
            })
            .execute();

        return id;
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

    public async deleteToken(id: string) : Promise<void> {
        const db = this.databaseService.getDb();
        const response = await db.deleteFrom('deviceToken')
            .where('id', '=', id)
            .execute()
    }

    public async deleteTokensOfUser(id: string) : Promise<void> {
        const db = this.databaseService.getDb();
        const response = await db.deleteFrom('deviceToken')
            .where('userId', '=', id)
            .execute()
    }

    public async disableTokensOfUser(userId: string) : Promise<void> {
        const db = this.databaseService.getDb();
        await db.updateTable('deviceToken')
            .set({
                disabled: true
            })
            .where('userId', '=', userId)
            .execute()
    }
}
