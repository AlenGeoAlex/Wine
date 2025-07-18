export const CONSTANTS = {

    MIDDLEWARE_KEYS : {
        API_KEY_USER: "API_KEY_USER"
    },

    CONFIG_KEYS : {
        GENERAL : {
            LOG_QUERY: "LOG_QUERY",
            ALLOWED_MIME_TYPES: "ALLOWED_MIME_TYPES",
            BASE_DOMAIN: "BASE_DOMAIN",
            NOT_FOUND_HTML: "NOT_FOUND_HTML"
        },

        DATABASE: {
            DATABASE_TYPE: "DATABASE_TYPE",
            SQLITE: {
                DATABASE_FILE_PATH: "DATABASE_FILE_PATH"
            },
            PG: {
                PG_DATABASE: "PG_DATABASE",
                PG_HOST: "PG_HOST",
                PG_PORT: "PG_PORT",
                PG_USER: "PG_USER",
                PG_PASSWORD: "PG_PASSWORD",
                PG_POOL_SIZE: "PG_POOL_SIZE"
            }
        },

        STORAGE : {
            STORAGE_PROVIDER : 'STORAGE_PROVIDER',
            FS: {
                FS_FILE_PATH : 'FS_FILE_PATH'
            },
            S3: {
                S3_BUCKET : 'S3_BUCKET',
                S3_ACCESS_KEY : 'S3_ACCESS_KEY',
                S3_SECRET_KEY : 'S3_SECRET_KEY',
                S3_REGION : 'S3_REGION',
                S3_ENDPOINT : 'S3_ENDPOINT',
                S3_PART_SIZE: 'S3_PART_SIZE',
                S3_PRESIGNED_UPLOAD: "S3_PRESIGNED_UPLOAD"
            }
        }
    },

    DEFAULTS: {
        DEFAULT_DATA_DIRECTORY: ["var", "lib", "wine-server", "data"]
    }
}