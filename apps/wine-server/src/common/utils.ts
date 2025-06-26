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

export interface IErrorResponse {
    message: string
    code: number
    meta?: Record<string, string>
}


export interface ICommandHandler<in T extends ICommandRequest<X>, out X extends ICommandResponse | IErrorResponse> {
    executeAsync(params: T): Promise<X>
}

