import {DeviceTokenTable, UserTable} from "./types/user.types";
import {UploadTable} from "./types/uploads.types";
import {Transaction} from "kysely";

export interface IDatabase {
    user: UserTable
    deviceToken: DeviceTokenTable
    upload: UploadTable
}

export interface IServiceOptions {
    trx?: Transaction<IDatabase>
}