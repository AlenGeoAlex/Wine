import { Kysely } from 'kysely'

export async function up(db: Kysely<any>): Promise<void> {
    await db.schema
        .alterTable('upload')
        .addColumn('isDeleted', 'boolean', (col) => col.defaultTo(false).notNull())
        .execute()

    await db.schema
        .alterTable('upload')
        .addColumn('deletedAt', 'timestamptz', (col) => col.defaultTo(null))
        .execute();

    await db.schema
        .alterTable('upload')
        .addColumn('deletedBy', 'text', (col) => col.defaultTo(null))
        .execute()
}

export async function down(db: Kysely<any>): Promise<void> {
    await db.schema
        .alterTable('upload')
        .dropColumn('deletedAt')
        .execute();

    await db.schema
        .alterTable('upload')
        .dropColumn('isDeleted')
        .execute();

    await db.schema
        .alterTable('upload')
        .dropColumn('deletedBy')
        .execute()
}