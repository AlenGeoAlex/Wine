import { Kysely } from 'kysely'

export async function up(db: Kysely<any>): Promise<void> {
    await db.schema
        .alterTable('upload')
        .addColumn('secret', 'text')
        .addColumn('secretHash', 'text')
        .execute()
}

export async function down(db: Kysely<any>): Promise<void> {
    await db.schema
        .alterTable('upload')
        .dropColumn('secret')
        .dropColumn('secretHash')
        .execute()
}