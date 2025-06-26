import {ICommandHandler, ICommandRequest, ICommandResponse, IPaginatedQuery, ISearchable} from "@common/utils";
import {UserService} from "@features/user/user.service";
import {IUser} from "common-models/dist/types/user.types";

export class ListUserCommand implements ICommandRequest<ListUserResponse>, IPaginatedQuery, ISearchable {
    searchTerm: string | undefined;
    skip: number | undefined;
    take: number | undefined;


    constructor(searchTerm: string | undefined, skip: number | undefined, take: number | undefined) {
        this.searchTerm = searchTerm;
        this.skip = skip;
        this.take = take;
    }
}

export class ListUserResponse implements ICommandResponse {
    private readonly _items: ReadonlyArray<IUser>

    constructor(items: IUser[]) {
        this._items = items;
    }


    get items(): ReadonlyArray<IUser> {
        return this._items;
    }
}

export class ListUserHandler implements ICommandHandler<ListUserCommand, ListUserResponse>{

    constructor(
        private readonly userService : UserService,
    ) {
    }

    async executeAsync(params: ListUserCommand): Promise<ListUserResponse> {

        const users = await this.userService.list({
            pagination: {
                skip: params.skip,
                take: params.take
            },
            search: {
                searchTerm: params.searchTerm,
            }
        });

        return new ListUserResponse(users);
    }

}