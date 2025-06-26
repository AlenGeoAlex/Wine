import {Injectable, Type} from "@nestjs/common";
import {ModuleRef} from "@nestjs/core";

@Injectable()
export class DIServiceProvider {
    constructor(private readonly moduleRef: ModuleRef) {}

    get<T>(type: Type<T>): T {
        return this.moduleRef.get(type, { strict: false });
    }
}
