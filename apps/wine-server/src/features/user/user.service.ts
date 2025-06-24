import {Inject, Injectable, Logger} from '@nestjs/common';
import {DB_PROVIDER} from "../../db/database.constants";
import {Kysely} from "kysely";
import {IDatabase} from "common-models";
import {NewUser, User} from "common-models/dist/types/user.types";
import {IPaginatedQuery, ISearchable} from "../../common/utils";
import {ulid} from "ulid";

@Injectable()
export class UserService {

    private readonly logger = new Logger(UserService.name);

    constructor(
        @Inject(DB_PROVIDER) private readonly db: Kysely<IDatabase>
    ) {
        this.logger.log("UserService constructor called");
    }

    public async create(from: NewUser) : Promise<string> {
        const id = ulid()
        await this.db
            .insertInto('user')
            .values({
                id: id,
                email: from.email,
                name: from.name,
                createdAt: from.createdAt
            })
            .executeTakeFirst()

        return id;
    }

    public async list(options: {
        pagination?: IPaginatedQuery,
        search?: ISearchable,
    }) :  Promise<User[]> {
        let query = this.db
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

    public async findById(id: string, options: {}) : Promise<User | undefined> {
        let query = this.db
            .selectFrom('user')
            .where('id', '=', id)

        return query.selectAll().executeTakeFirst();
    }

    public async findByEmail(email: string): Promise<User | undefined> {
        let query = this.db
            .selectFrom('user')
            .where('email', '=', email)

        return query.selectAll().executeTakeFirst();
    }


}
