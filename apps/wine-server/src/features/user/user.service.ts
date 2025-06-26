import {Injectable, Logger} from '@nestjs/common';
import {IUser, NewUser, UpdateUser, User} from "common-models/dist/types/user.types";
import {IPaginatedQuery, ISearchable} from "@common/utils";
import {ulid} from "ulid";
import {DatabaseService} from "@db/database";

@Injectable()
export class UserService {

    private readonly logger = new Logger(UserService.name);

    constructor(
        private readonly databaseService : DatabaseService,
    ) {
        this.logger.log("UserService constructor called");
    }

    public async create(from: IUser, options?: {}) : Promise<string> {
        this.logger.log("Trying to create a user with ", from)
        const id = ulid()
        const db = this.databaseService.getDb();
        await db
            .insertInto('user')
            .values({
                id: id,
                email: from.email!,
                name: from.name!,
                createdAt: from.createdAt!.toISOString(),
                disabled: this.databaseService.parseBoolean(false),
            })
            .executeTakeFirst()

        return id;
    }

    public async list(options: {
        pagination?: IPaginatedQuery,
        search?: ISearchable,
    }) :  Promise<User[]> {
        const db = this.databaseService.getDb();
        let query = db
            .selectFrom('user');

        if(options.search?.searchTerm){
            const searchPattern = `%${options.search.searchTerm}%`;
            query = query.where((builder) => builder.or([
                builder('email', 'like', searchPattern),
                builder('name', "like" ,searchPattern),
            ]));
        }

        if(Number.isFinite(options.pagination?.skip) && Number.isFinite(options.pagination?.skip)) {
            const skip = options.pagination?.skip ?? 0;
            const take = options.pagination?.take ?? 0;

            query = query
                .offset(skip)
                .limit(take);

            this.logger.log('list: Applied pagination', { skip, take });
        }

        return await query
            .selectAll().execute();
    }

    public async findById(id: string, options?: {}) : Promise<User | undefined> {
        const db = this.databaseService.getDb();
        let query = db
            .selectFrom('user')
            .where('id', '=', id)

        return query.selectAll().executeTakeFirst();
    }

    public async findByEmail(email: string, options?: {}): Promise<User | undefined> {
        const db = this.databaseService.getDb();
        let query = db
            .selectFrom('user')
            .where('email', '=', email)

        return query.selectAll().executeTakeFirst();
    }

    public async update(id: string, user: IUser, options?: {
        isIdentityAsEmail: boolean,
    }) : Promise<boolean> {
        this.logger.log(`Trying to update user ${id} with `, user)
        const db = this.databaseService.getDb();
        let query = db.updateTable('user');
        let hasMutations = false;
        if(user.name){
            query = query.set({
                name: user.name
            });
            hasMutations = true;
        }

        if(typeof user.disabled !== 'undefined'){
            query = query.set({
                disabled: this.databaseService.parseBoolean(user.disabled)
            });
            hasMutations = true;
        }

        if(!hasMutations)
            return false;

        if(options?.isIdentityAsEmail ?? false){
            this.logger.log("Updating user with email as identity")
            query = query
                .where('email', '=', id)
        }

        let result = await query.execute();
        if(!result || result.length === 0)
            return false;

        const updateResult = result[0];
        return updateResult.numUpdatedRows >= 0;
    }

    public async deleteUser(id: string) {
        await this.databaseService.getDb()
            .deleteFrom('user')
            .where('id', '=', id)
            .execute();
    }


}
