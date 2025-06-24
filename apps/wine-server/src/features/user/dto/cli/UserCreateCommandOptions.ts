import {IsEmail, IsOptional, Length} from "class-validator";
import {Option} from "nest-commander";

export class UserCreateCommandOptions {

    @Length(0)
    name: string
    @IsEmail()
    email: string

}