import {DeviceTokenTable, UserTable} from "./types/user.types";
import {UploadTable} from "./types/uploads.types";

export interface IDatabase {
    user: UserTable
    deviceToken: DeviceTokenTable
    upload: UploadTable
}