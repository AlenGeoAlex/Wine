import type {IViewResponse} from "@/lib/models/view.model.ts";
import type {IFileContentResponse, IFileInfoResponse} from "@/lib/models/api-dto.models.ts";

export class FileApiService {

    public static async getContent(id: string, secret: string, options? : {}) : Promise<IViewResponse<IFileContentResponse>> {
        try {
            const url = new URL(`/api/v1/file/${id}/content`, window.location.origin)
            const response = await fetch(url);
            if(!response.ok){
                if(response.status === 404){
                    return {
                        success: false,
                        response: undefined,
                        error: "Media not found"
                    }
                }
            }

            if([301, 302].includes(response.status)){
                const location = response.headers.get("Location");
                if(!location){
                    return {
                        success: false,
                        response: undefined,
                        error: "Failed to find the actual location of the file"
                    }
                }

                return {
                    success: true,
                    response: {
                        content: location
                    }
                }
            }

            const data = await response.blob();
            return {
                success: true,
                response: {
                    content: URL.createObjectURL(data)
                }
            }
        }catch (e) {
            return {
                success: false,
                response: undefined,
                error: "Failed to get file content"
            }
        }
    }

    public static async getInfo(id: string, options? : {}) : Promise<IViewResponse<IFileInfoResponse>> {
        try {
            const url = new URL(`/api/v1/file/${id}`, window.location.origin)
            const response = await fetch(url);
            if(!response.ok){
                if(response.status === 404){
                    return {
                        success: false,
                        response: undefined,
                        error: "Media not found"
                    }
                }

                return {
                    success: false,
                    response: undefined,
                    error: "Failed to get media info"
                }
            }

            const data = await response.json();
            return {
                success: true,
                response: data
            }
        }catch (e) {
            return {
                success: false,
                response: undefined,
                error: "Failed to get file info"
            }
        }
    }

}