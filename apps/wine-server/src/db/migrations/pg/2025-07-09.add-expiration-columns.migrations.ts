import { Kysely } from 'kysely'

export async function up(db: Kysely<any>): Promise<void> {
    await db.schema
        .alterTable('upload')
        .addColumn('expiration', 'timestamptz', (col) => col.defaultTo(false).notNull())
        .execute();
}

export async function down(db: Kysely<any>): Promise<void> {
    await db.schema
        .alterTable('upload')
        .dropColumn('expiration')
        .execute()
}