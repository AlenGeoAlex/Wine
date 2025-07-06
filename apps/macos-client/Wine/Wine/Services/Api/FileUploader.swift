//
//  FileUploader.swift
//  Wine
//
//  Created by Alen Alex on 06/07/25.
//

import Foundation
import OSLog
import FactoryKit
import Combine

class FileUploader: NSObject, URLSessionTaskDelegate {
    private var progressCallback: ((Double) -> Void)?
    private var logger = Logger(subsystem: AppConstants.reversedDomain, category: "FileUploader")
    

    func uploadFile(
        id: String,
        for capturedFile: CapturedFile,
        progressHandler: @escaping (Double) -> Void
    ) async -> URL? {
        do {
            self.progressCallback = progressHandler
            let settingsService = Container.shared.settingsService.resolve();
            let type = await settingsService.uploadSettings.type

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
            urlRequest.setValue("Token \(settings.secureToken)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("Wine-MacOS", forHTTPHeaderField: "User-Agent")

            let fileName = await capturedFile.fileName
            let mimeType = await capturedFile.mimeType

            var body = Data()
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=file; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType) \r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)

            let task = session.uploadTask(with: urlRequest, from: body)
            let (data, response) = try await withCheckedThrowingContinuation { continuation in
                self.completion = { result in
                    continuation.resume(with: result)
                }
                task.resume()
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.error("Server error: \(response)")
                return nil
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                logger.error("Invalid response body")
                return nil
            }

            let domain = json["domain"] as? String ?? settings.serverAddress.absoluteString
            guard let fileId = json["fileId"] as? String else {
                logger.error("Missing fileId in response")
                return nil
            }

            logger.info("Domain has been set to \(domain) and fileId is \(fileId)")
            return URL(string: domain)!.appendingPathComponent(fileId)
        } catch {
            logger.error("\(error)")
            return nil
        }
    }

    private var completion: ((Result<(Data, URLResponse), Error>) -> Void)?

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didSendBodyData bytesSent: Int64, totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        let percent = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            self.progressCallback?(percent)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            completion?(.failure(error))
        } else if let response = task.response,
                  let data = (task as? URLSessionUploadTask)?.originalRequest?.httpBody {
            completion?(.success((data, response)))
        }
    }
}
