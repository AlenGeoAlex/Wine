import {ColumnType, Insertable, Selectable, Updateable} from "kysely";


export interface UserTable {
    id: ColumnType<string, string, never>
    name: string
    email: string
    disabled: ColumnType<boolean, boolean | number, boolean | number | undefined>
    createdAt: ColumnType<Date, Date | string, never>
}

export type User = Selectable<UserTable>
export type UpdateUser = Updateable<UserTable>
export type NewUser = Insertable<UserTable>

export interface DeviceTokenTable {
    id: ColumnType<string, string, never>
    token: string
    expiry : Date | null
    disabled: ColumnType<boolean, boolean | number, boolean | number | undefined>
    createdAt: ColumnType<Date, Date | string, never>
    userId: ColumnType<string, string, never>
}

export type DeviceToken = Selectable<DeviceTokenTable>
export type UpdateDeviceToken = Updateable<DeviceTokenTable>
export type NewDeviceToken = Insertable<DeviceTokenTable>

