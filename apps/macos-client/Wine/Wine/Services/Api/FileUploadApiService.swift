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
    
    func listUploads(request: FileListQuery) async -> Result<FileListResponse, Error> {
        do {
            let type = await self.settingsService.uploadSettings.type
            
            guard case let .wine(settings) = type else {
                return .failure(UploadServiceError.unknownProvider)
            }
            
            var requestUrl = settings.serverAddress.appending(path: "api/v1/file")
            requestUrl.append(queryItems: [
                URLQueryItem(name: "take", value: String(request.take ?? 10)),
                URLQueryItem(name: "skip", value: String(request.skip ?? 0))
            ])
            var httpRequest = URLRequest(url: requestUrl);
            logger.info("Setting the request url to \(requestUrl)")
            httpRequest.httpMethod = "GET"
            httpRequest.setValue("Token \(settings.secureToken)", forHTTPHeaderField: "Authorization");
            httpRequest.setValue("Wine-MacOS", forHTTPHeaderField: "User-Agent")
            httpRequest.timeoutInterval = 30
            
            let (data, response) = try await URLSession.shared.data(for: httpRequest)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                self.logger.log("Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                self.logger.log("\(String(data: data, encoding: .utf8) ?? "No data")")
                return .failure(UploadServiceError.unknown)
            }
                        
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601withFractionalSeconds)
                let listResponse = try decoder.decode(FileListResponse.self, from: data)
                return .success(listResponse)
            } catch {
                return .failure(error)
            }
        } catch {
            logger.error("Failed to list the uploads \(error)")
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
        httpRequest.timeoutInterval = 30
        
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
            self.logger.log("\(String(data: data, encoding: .utf8) ?? "No data")")
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
        
        let requestUrl = settings.serverAddress.appending(path: "api/v1/file/\(id)/content")
        let boundary = UUID().uuidString
        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Token \(settings.secureToken)", forHTTPHeaderField: "Authorization");
        urlRequest.setValue("Wine-MacOS", forHTTPHeaderField: "User-Agent")
        
        let fileName = await capturedFile.fileName
        let mimeType = await capturedFile.mimeType
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=file; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType) \r\n\r\n".data(using: .utf8)!)
        data.append(fileData)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        urlRequest.httpBody = data
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.error("Server error: \(response)")
                return nil
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                logger.error("\(data)")
                logger.error("Invalid response body")
                return nil
            }
            
            var domain: String?
            domain = json["domain"] as? String ?? settings.serverAddress.absoluteString;
            let fileId = json["fileId"] as? String;
            
            if(domain == nil || fileId == nil){
                logger.error("\(data)")
                logger.error("Failed to read the domain and fileId")
                return nil
            }
            logger.info("Domain has been set to \(domain!) and fileId is \(fileId!)")
            
            let finalUrl = URL(string: domain!)!.appendingPathComponent(fileId!)
            return finalUrl;
        } catch {
            logger.error("Upload failed: \(error)")
            return nil
        }
    }
    
}
