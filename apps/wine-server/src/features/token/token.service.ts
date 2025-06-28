import {Injectable, Logger} from '@nestjs/common';
import {DatabaseService} from "@db/database";
import {NewDeviceToken} from "common-models/dist/types/user.types";
import {ulid} from "ulid";
import {EventEmitter2} from "@nestjs/event-emitter";
import {namespaceOf} from "@common/events";
import {TokenRevokedEvent} from "@features/token/dto/events/events";
import {IServiceOptions} from "common-models";

@Injectable()
export class TokenService {

    private readonly logger = new Logger(TokenService.name);

    constructor(
        private readonly databaseService : DatabaseService,
        private readonly eventEmitter : EventEmitter2
    ) {
    }

    public async create(token: NewDeviceToken, options? : IServiceOptions): Promise<string> {
        const db = options?.trx ?? this.databaseService.getDb();
        const id = ulid();
        let result = await db.insertInto('deviceToken')
            .values({
                id: id,
                token: token.token,
                createdAt: token.createdAt.toString(),
                disabled: this.databaseService.parseBoolean(false),
                userId: token.userId,
            })
            .execute();

        return id;
    }

    public async getUserIdByToken(token: string, options?:  IServiceOptions) : Promise<{
        userId: string,
        expiresAt: Date | null,
    } | undefined> {
        const db = options?.trx ?? this.databaseService.getDb();
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

    public async deleteToken(id: string, options? :  IServiceOptions) : Promise<void> {
        const db = options?.trx ?? this.databaseService.getDb();
        const response = await db.deleteFrom('deviceToken')
            .where('id', '=', id)
            .execute()

        this.eventEmitter.emitAsync(namespaceOf("deleted", "token"), {
            id: id,
        }).catch(e => {
            this.logger.error(e);
        })
    }

    public async deleteTokensOfUser(id: string, options? :  IServiceOptions) : Promise<void> {
        const db = options?.trx ?? this.databaseService.getDb();
        const response = await db.deleteFrom('deviceToken')
            .where('userId', '=', id)
            .execute();

        this.eventEmitter.emitAsync(namespaceOf('revoked', 'token'), {
            id: id,
            revokedBy: 'user',
        } as TokenRevokedEvent)
            .catch(e => {
                this.logger.error(e);
            })
    }

    public async disableTokensOfUser(userId: string, options?:  IServiceOptions) : Promise<void> {
        const db = options?.trx ?? this.databaseService.getDb();
        await db.updateTable('deviceToken')
            .set({
                disabled: true
            })
            .where('userId', '=', userId)
            .execute()

        this.eventEmitter.emitAsync(namespaceOf('revoked', 'token'), {
            id: userId,
            revokedBy: 'user',
        } as TokenRevokedEvent)
            .catch(e => {
                this.logger.error(e);
            })
    }
}
