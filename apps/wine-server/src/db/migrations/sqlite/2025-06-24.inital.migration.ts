import {Kysely, sql} from 'kysely'

export async function up(db: Kysely<any>): Promise<void> {
    await db.schema
        .createTable('user')
        .addColumn('id', 'varchar(40)', (col) => col.primaryKey().notNull())
        .addColumn('email', 'text', (col) => col.notNull().unique())
        .addColumn('name', 'text')
        .addColumn('createdAt', 'text', (col) =>
            col.defaultTo(sql`CURRENT_TIMESTAMP`).notNull(),
        )
        .addColumn('disabled', 'boolean', (col) => col.defaultTo(false).notNull())
        .execute()

    await db.schema
        .createTable('deviceToken')
        .addColumn('id', 'varchar(40)', (col) => col.primaryKey().notNull())
        .addColumn('token', 'text', (col) => col.notNull().unique())
        .addColumn('expiry', 'text', (col) => col.defaultTo(sql`null`))
        .addColumn('createdAt', 'text', (col) =>
            col.defaultTo(sql`CURRENT_TIMESTAMP`).notNull(),
        )
        .addColumn('userId', 'varchar(40)', (col) => col.notNull().references('user.id').onUpdate('cascade').onDelete('cascade'))
        .addColumn('disabled', 'boolean', (col) => col.defaultTo(false).notNull())
        .execute()

    await db.schema
        .createTable('upload')
        .addColumn('id', 'varchar(40)', (col) => col.primaryKey().notNull())
        .addColumn('fileKey', 'text')
        .addColumn('status', 'text', (col) => col.defaultTo('created').notNull())
        .addColumn('fileName', 'text', (col) => col.notNull())
        .addColumn('contentType', 'text', (col) => col.notNull())
        .addColumn('tags', 'text', (col) => col.notNull().defaultTo('[]'))
        .addColumn('size', "decimal", (col) => col.notNull().defaultTo('0'))
        .addColumn('createdAt', 'text', (col) =>
            col.defaultTo(sql`CURRENT_TIMESTAMP`).notNull(),
        )
        .addColumn('extension', 'varchar(10)', (col) => col.notNull().defaultTo(''))
        .addColumn('userId', 'varchar(40)', (col) => col.notNull().references('user.id').onUpdate('cascade').onDelete('cascade'))
        .addUniqueConstraint("UNQ_unique_fileKey_user", ["fileKey", "userId"])
        .execute();
}

export async function down(db: Kysely<any>): Promise<void> {
    await db.schema.dropTable('deviceToken').ifExists().execute()
    await db.schema.dropTable('upload').ifExists().execute()
    await db.schema.dropTable('user').ifExists().execute()
}