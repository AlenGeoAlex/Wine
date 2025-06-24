import {IsInt, IsOptional, Min} from "class-validator";
import {Transform} from "class-transformer";
import { Option } from 'nest-commander';

export class UserListCommandOptions {

    @IsOptional()
    @Transform(({ value }) => parseInt(value))
    @IsInt({ message: 'Skip must be a valid integer' })
    @Min(0, { message: 'Skip must be a positive integer' })
    // @ts-ignore
    @Option({
        flags: '-s, --skip <skip>',
        description: 'Skip the first <skip> users',
    })
    skip?: number;


    @IsOptional()
    @Transform(
        ({value}) => parseInt(value)
    )
    @IsInt({message: "Take must be a valid integer"})
    @Min(1,  {message: "Take must be a positive integer greater than 0"})
    // @ts-ignore
    @Option({
        flags: '-t, --take <take>',
        description: 'Take the users',
    })
    take?: number

    @IsOptional()
    // @ts-ignore
    @Option({
        flags: '-q, --query <search>',
        description: 'Search for users by name or email',
    })
    search? : string
}