//
//  FileUploadService.swift
//  Wine
//
//  Created by Alen Alex on 28/06/25.
//

import Foundation
import OSLog
import FactoryKit

class FileUploadApiService {
    
    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "FileUploadApiService")
    @Injected(\.settingsService) private var settingsService : SettingsService
    
    func pingServer(url: URL?) async -> Result<Void, Error> {
        do {
            guard let url = url else {
                return .failure(UploadServiceError.unknown)
            }
            
            let requestUrl = url.appending(path: "api/v1/app");
            let (_, response) = try await URLSession.shared.data(from: requestUrl)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(UploadServiceError.unknown)
            }
            
            return .success(())
        }
        catch
        {
            logger.error("Failed to ping the server due to \(error)")
            return .failure(error)
        }
    }
    
    
    func createFile(with request: FileUploadRequest) async throws -> FileUploadResponse {
        let type = await self.settingsService.uploadSettings.type
        
        guard case let .wine(settings) = type else {
            throw UploadServiceError.unknownProvider
        }
        
        let requestUrl = settings.serverAddress.appending(path: "api/v1/file")
        var httpRequest = URLRequest(url: requestUrl);
        logger.info("Setting the request url to \(requestUrl)")
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
        httpRequest.setValue("Token \(settings.secureToken)", forHTTPHeaderField: "Authorization");
        httpRequest.setValue("Wine-MacOS", forHTTPHeaderField: "User-Agent")
        httpRequest.timeoutInterval = 10
        
        let encoder = JSONEncoder()
        do {
            let bodyData = try encoder.encode(request)
            httpRequest.httpBody = bodyData
        } catch {
            throw UploadServiceError.decodingError(error)
        }

        
        let (data, response) = try await URLSession.shared.data(for: httpRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            self.logger.log("Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            throw UploadServiceError.failedToCreate;
        }
        
        do {
            let decoder = JSONDecoder()
            let createdPost = try decoder.decode(FileUploadResponse.self, from: data)
            return createdPost
        } catch {
            throw UploadServiceError.decodingError(error)
        }
    }
    
    func uploadFile(id: String, for capturedFile : CapturedFile) async ->  URL? {
        let type = await self.settingsService.uploadSettings.type
        
        guard case let .wine(settings) = type else {
            logger.error("Not able to upload file. Unknown provider")
            return nil
        }
        
        guard let fileData = try? Data(contentsOf: capturedFile.fileContent) else {
            print("Failed to read file data")
            return nil
        }
        
        let requestUrl = settings.serverAddress.appending(path: "api/v1/file/upload/\(id)")
        let boundary = UUID().uuidString
        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Token \(settings.secureToken)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("Wine-MacOS", forHTTPHeaderField: "User-Agent")
        
        let fileName = capturedFile.fileName
        let mimeType = capturedFile.mimeType
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=file; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType) \r\n\r\n".data(using: .utf8)!)
        data.append(fileData)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        urlRequest.httpBody = data
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                logger.error("Server error: \(response)")
                return nil
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let uploadedUrlString = json["url"] as? String,
               let uploadedUrl = URL(string: uploadedUrlString) {
                return uploadedUrl
            } else {
                logger.error("\(data)")
                logger.error("Invalid response body")
                return nil
            }
        } catch {
            logger.error("Upload failed: \(error)")
            return nil
        }
    }
    
}
