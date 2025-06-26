// src/db/database.service.ts

import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
    Dialect,
    FileMigrationProvider,
    Kysely,
    Migrator,
    ParseJSONResultsPlugin,
    PostgresDialect,
    SqliteDialect,
    LogLevel,
} from 'kysely';
import * as SQLite from 'better-sqlite3';
import { Pool } from 'pg';
import { promises as fs, mkdirSync } from 'fs';
import * as path from 'path';
import { IDatabase } from 'common-models'; // Adjust path if needed
import { CONSTANTS } from '@common/constants'; // Adjust path if needed
import { DatabaseProvider } from '@common/enums'; // Adjust path if needed

@Injectable()
export class DatabaseService implements OnModuleInit {
    private readonly logger = new Logger(DatabaseService.name);
    private dbInstance: Kysely<IDatabase>;

    constructor(private readonly configService: ConfigService) {}

    /**
     * This lifecycle hook is called once the module's dependencies are resolved.
     * It's the perfect place to initialize the database and run migrations.
     */
    async onModuleInit(): Promise<void> {
        this.logger.log('Initializing database connection...');
        await this.createKyselyInstance();

        this.logger.log('Running database migrations...');
        await this.tryMigrate();

        this.logger.log('Database initialization and migration complete.');
    }

    /**
     * Public getter to allow other providers to access the Kysely instance.
     */
    getDb(): Kysely<IDatabase> {
        if (!this.dbInstance) {
            throw new Error('Database has not been initialized. Ensure onModuleInit has completed.');
        }
        return this.dbInstance;
    }

    private async createKyselyInstance(): Promise<void> {
        const provider = this.getDatabaseProvider();
        this.logger.log(`Using ${provider} database`);
        let dialect: Dialect;

        if (provider === DatabaseProvider.SQLITE) {
            const defaultDirArray = CONSTANTS.DEFAULTS.DEFAULT_DATA_DIRECTORY;
            const pathSegments = [...defaultDirArray];
            const defaultPath = path.join(...pathSegments);
            const databaseFolder = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.DATABASE.SQLITE.DATABASE_FILE_PATH, defaultPath);
            const databasePath = path.join(databaseFolder, 'wine.db');

            this.logger.log(`Connecting to sqlite database: ${databasePath}`);
            const dir = path.dirname(databasePath);

            try {
                mkdirSync(dir, { recursive: true });
                this.logger.log(`Ensured database directory exists: ${dir}`);
            } catch (error) {
                this.logger.error(`Failed to create database directory: ${dir}`, error);
                throw error;
            }
            dialect = new SqliteDialect({
                database: new SQLite(databasePath),
            });
        } else {
            const databaseName = process.env[CONSTANTS.CONFIG_KEYS.DATABASE.PG.PG_DATABASE] ?? "wine";
            const databaseUser = process.env[CONSTANTS.CONFIG_KEYS.DATABASE.PG.PG_USER];
            const databasePassword = process.env[CONSTANTS.CONFIG_KEYS.DATABASE.PG.PG_PASSWORD];
            const databaseHost = process.env[CONSTANTS.CONFIG_KEYS.DATABASE.PG.PG_HOST];
            const databasePort = process.env[CONSTANTS.CONFIG_KEYS.DATABASE.PG.PG_PORT] ?? "5432";
            const poolSize = process.env[CONSTANTS.CONFIG_KEYS.DATABASE.PG.PG_POOL_SIZE] ?? "10";

            if(!databaseHost || !databaseUser || !databasePassword || !databaseName || !databasePort){
                throw new Error("DATABASE_PG_HOST, DATABASE_PG_USER, DATABASE_PG_PASSWORD, DATABASE_PG_DATABASE are not set");
            }
            this.logger.log(
                `Connecting to postgres database ${databaseName} on ${databaseHost}:${databasePort} as ${databaseUser}`
            )

            dialect = new PostgresDialect({
                pool: new Pool({
                    database: databaseName,
                    host: databaseHost,
                    user: databaseUser,
                    port: Number.parseInt(databasePort),
                    max: Number.parseInt(poolSize),
                })
            })
        }

        const logLevels: LogLevel[] = this.configService.get<string>('LOG_QUERY') === 'true'
            ? ['query', 'error']
            : ['error'];

        this.dbInstance = new Kysely<IDatabase>({
            log: logLevels,
            dialect,
            plugins: [new ParseJSONResultsPlugin()],
        });
    }

    private async tryMigrate(): Promise<void> {
        const migrator = new Migrator({
            db: this.dbInstance,
            provider: new FileMigrationProvider({
                fs,
                path,
                migrationFolder: path.join(__dirname, 'migrations', this.getDatabaseProvider().toLowerCase()),
            }),
            allowUnorderedMigrations: false,
        });

        const { error, results } = await migrator.migrateToLatest();

        results?.forEach((it) => {
            if (it.status === 'Success') {
                this.logger.log(`Migration "${it.migrationName}" was executed successfully`);
            } else if (it.status === 'Error') {
                this.logger.error(`Failed to execute migration "${it.migrationName}"`);
            }
        });

        if (error) {
            this.logger.error('Failed to migrate database', error);
            throw error; // Throwing error will stop the application bootstrap
        }
    }

    private getDatabaseProvider(): DatabaseProvider {
        const dbType = this.configService.get<string>(CONSTANTS.CONFIG_KEYS.DATABASE.DATABASE_TYPE)?.toUpperCase();
        if (!dbType || (dbType !== DatabaseProvider.SQLITE && dbType !== DatabaseProvider.PG)) {
            throw new Error(`DATABASE_TYPE is not set or is unsupported: '${dbType}'`);
        }
        return dbType;
    }
}