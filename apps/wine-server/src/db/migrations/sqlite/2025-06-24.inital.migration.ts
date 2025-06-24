import {Kysely, sql} from 'kysely'

export async function up(db: Kysely<any>): Promise<void> {
    await db.schema
        .createTable('user')
        .addColumn('id', 'varchar(40)', (col) => col.primaryKey().notNull())
        .addColumn('email', 'text', (col) => col.notNull().unique())
        .addColumn('name', 'text')
        .addColumn('created_at', 'text', (col) =>
            col.defaultTo(sql`CURRENT_TIMESTAMP`).notNull(),
        )
        .execute()

    await db.schema
        .createTable('deviceToken')
        .addColumn('id', 'varchar(40)', (col) => col.primaryKey().notNull())
        .addColumn('token', 'text', (col) => col.notNull().unique())
        .addColumn('expiry', 'text', (col) => col.defaultTo(sql`null`))
        .addColumn('created_at', 'text', (col) =>
            col.defaultTo(sql`CURRENT_TIMESTAMP`).notNull(),
        )
        .addColumn('userId', 'varchar(40)', (col) => col.notNull().references('user.id').onUpdate('cascade').onDelete('cascade'))
        .execute()

    await db.schema
        .createTable('upload')
        .addColumn('id', 'varchar(40)', (col) => col.primaryKey().notNull())
        .addColumn('fileKey', 'text', (col) => col.notNull().unique())
        .addColumn('status', 'text', (col) => col.defaultTo('created').notNull())
        .addColumn('fileName', 'text', (col) => col.notNull())
        .addColumn('contentType', 'text', (col) => col.notNull())
        .addColumn('tags', 'text', (col) => col.notNull().defaultTo('[]'))
        .addColumn('size', "decimal", (col) => col.notNull().defaultTo('0'))
        .addColumn('created_at', 'text', (col) =>
            col.defaultTo(sql`CURRENT_TIMESTAMP`).notNull(),
        )
        .execute();

    await db.insertInto('user').values({
        id: '00000000-0000-0000-0000-000000000000',
        name: 'Default User',
        email: 'default@default.com',
        created_at: new Date().toISOString()
    }).onConflict((db) => db.column('email')
            .doNothing())
        .execute();

    await db.insertInto('deviceToken').values({
        id: '00000000-0000-0000-0000-000000000000',
        token: '01JYHMKJKAGB00BFFQBGXJ01JZVN7R0NAEC0ZYHTTNK',
        userId: '00000000-0000-0000-0000-000000000000',
        created_at: new Date().toISOString()
    }).onConflict((db) => db.column('token').doNothing())
        .execute();

}

export async function down(db: Kysely<any>): Promise<void> {
    await db.schema.dropTable('user').execute()
    await db.schema.dropTable('deviceToken').execute()
    await db.schema.dropTable('upload').execute()
}