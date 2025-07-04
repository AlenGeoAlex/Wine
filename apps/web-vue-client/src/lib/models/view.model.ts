export interface IViewResponse<TData> {
    success: boolean
    response: TData | undefined
    error?: string
}