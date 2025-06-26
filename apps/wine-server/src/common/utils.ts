export interface IPaginatedQuery {
    skip: number | undefined
    take: number | undefined
}

export interface ISearchable {
    searchTerm: string | undefined
}

export interface ICommandRequest<out R> {

}

export interface ICommandResponse{

}


export interface ICommandHandler<in T extends ICommandRequest<X>, out X extends ICommandResponse> {
    executeAsync(params: T): Promise<X>
}

