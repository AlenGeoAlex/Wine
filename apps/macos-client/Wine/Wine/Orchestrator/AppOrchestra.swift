//
//  ScreenshotOrchestra.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import Foundation
import OSLog
import FactoryKit
@preconcurrency import AppKit
import ClopSDK

class AppOrchestra : ObservableObject {
    
    private let logger : Logger =  Logger(subsystem: AppConstants.reversedDomain, category: "ScreenshotOrchestra")
    
    private let settingsService : SettingsService;
    private let screenshotCapture : ImageCaptureProtocol;
    private let clopIntegration : ClopIntegration;
    private let previewOverlayService: OverlayWindowService;
    private let fileUploadApiService : FileUploadApiService;
    
    
    init(container: Container) {
        self.settingsService = container.settingsService.resolve()
        self.screenshotCapture = container.imageCaptureProtocol.resolve()
        self.clopIntegration = container.clopIntegration.resolve()
        self.previewOverlayService = container.previewOverlayService.resolve()
        self.fileUploadApiService = container.fileUploadApi.resolve()
    }
    
    func takeSnip() async -> Void {
        do {
            let image = try await self.screenshotCapture.captureImageWithSelection();
            var url = try image.get();
            
            logger.info("File has been saved to \(url)")
            guard let _ = NSImage(contentsOf: url) else {
                logger.error("Failed to take snip")
                return;
            }
  
            let finalUrl = await optimizeFile(url: url);

            guard let _ = NSImage(contentsOf: finalUrl) else {
                logger.error("Failed to create NSImage from URL: \(finalUrl)")
                return
            }

            let capture = CapturedFile(
                fileContent: finalUrl, type: .png, captureType: .screenshot
            )

            await preparePreview(capturedFile: capture)
            
            logger.info("URL is \(url)")
        }catch {
            logger.error("Failed to take snip \(error)")
        }
    }
    
    func completeVideoSnip(url: URL) async -> Void {
        let finalUrl = await optimizeFile(url: url);
        let capture = CapturedFile(
            fileContent: finalUrl, type: .mp4, captureType: .video
        )

        await preparePreview(capturedFile: capture)
    }
    
    private func preparePreview(capturedFile: CapturedFile) async -> Void{
        await MainActor.run {
            previewOverlayService.showPreview(with: capturedFile)
        }
    }
    
    private func optimizeFile(url: URL) async -> URL {
        let clopUrl = await clopIntegration.run(forContentOf: url)
        switch clopUrl {
        case .failure(let error):
            logger.error("Failed to send to clop \(error)")
            return url;
        case .success(let clopResponse):
            return clopResponse;
        }
    }
    
    func tryUpload(capturedFile : CapturedFile) async -> Result<Bool, UploadServiceError>  {
        do {
            var fileName : String;
            var ext = "png"
            let size = try FileHelpers.getFileSize(at: capturedFile.fileContent)
            let tags = [] as [String];
            var contentType = "image/png";
            let expiration: Date? = nil;
            switch capturedFile.captureType {
            case .screenshot:
                fileName = "screenshot.png"
                ext = "png"
                contentType = "image/png"
            case .video:
                fileName = "video.mp4"
                ext = "mp4"
                contentType = "video/mp4"
            }
            let fileRequest = FileUploadRequest(fileName: fileName, ext: ext, size: size, tags: tags, contentType: contentType, expiration: expiration)
            
            let createResponse = try await self.fileUploadApiService.createFile(with: fileRequest);
            
            self.logger.info("Recieved response to upload to cloud with id \(createResponse.id) and uploadType with \(createResponse.uploadType.rawValue)")
            
            var uploadUrl : URL?;
            switch createResponse.uploadType {
            case .direct:
                uploadUrl = await createUploadDirectly(for: capturedFile, with: createResponse);
            case .presigned:
                uploadUrl = await createS3Upload(for: capturedFile, with: createResponse);
            }
            
            logger.info("\(uploadUrl?.absoluteString ?? "")")
            if uploadUrl != nil {
                ClipboardHelper.copyStringToClipboard(uploadUrl?.absoluteString ?? "")
                let fileDeleteReponse = FileHelpers.delete(file: capturedFile.fileContent)
                switch fileDeleteReponse {
                case .success:
                    logger.info("File deleted successfully")
                case .failure(let error):
                    logger.error("Failed to delete file \(error)")
                }
            }
            return .success(true);
        }
        catch
        {
            logger.error("Failed to upload \(error)")
            return .failure(.unknown);
        }
    }
    
    func createUploadDirectly(for capturedFile : CapturedFile, with response : FileUploadResponse) async -> URL? {
        return await self.fileUploadApiService.uploadFile(id: response.id, for: capturedFile)
    }
    
    
    func createS3Upload(for capturedFile : CapturedFile, with response : FileUploadResponse) async -> URL? {
        return nil
    }
    
}
