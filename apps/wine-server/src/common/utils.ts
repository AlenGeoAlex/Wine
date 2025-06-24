export interface IPaginatedQuery {
    skip: number | undefined
    take: number | undefined
}

export interface ISearchable {
    searchTerm: string | undefined
}
