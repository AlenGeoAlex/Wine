import { Kysely, sql } from 'kysely'

export async function up(db: Kysely<any>): Promise<void> {
    await db.schema
        .createTable('user')
        .addColumn('id', 'varchar(40)', (col) => col.primaryKey().notNull())
        .addColumn('email', 'text', (col) => col.notNull().unique())
        .addColumn('name', 'text')
        .addColumn('created_at', 'timestamptz', (col) => // Use timestamptz for PostgreSQL
            col.defaultTo(sql`now()`).notNull(),
        )
        .execute()

    await db.schema
        .createTable('deviceToken')
        .addColumn('id', 'varchar(40)', (col) => col.primaryKey().notNull())
        .addColumn('token', 'text', (col) => col.notNull().unique())
        .addColumn('expiry', 'timestamptz')
        .addColumn('created_at', 'timestamptz', (col) =>
            col.defaultTo(sql`now()`).notNull(),
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
        .addColumn('tags', 'jsonb', (col) => col.notNull().defaultTo('[]'))
        .addColumn('size', "numeric", (col) => col.notNull().defaultTo('0'))
        .addColumn('created_at', 'timestamptz', (col) =>
            col.defaultTo(sql`now()`).notNull(),
        )
        .execute();
}

export async function down(db: Kysely<any>): Promise<void> {
    await db.schema.dropTable('deviceToken').ifExists().execute()
    await db.schema.dropTable('upload').ifExists().execute()
    await db.schema.dropTable('user').ifExists().execute()
}