//
//  ScreenshotOrchestra.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import Foundation
import OSLog
import FactoryKit
import AppKit
import ClopSDK

class AppOrchestra : ObservableObject {
    
    private let logger : Logger =  Logger(subsystem: AppConstants.reversedDomain, category: "ScreenshotOrchestra")
    
    private let settingsService : SettingsService;
    private let screenshotCapture : ImageCaptureProtocol;
    private let clopIntegration : ClopIntegration;
    private let previewOverlayService: OverlayWindowService;
    
    init(settingsService: SettingsService, screenshotCapture: ImageCaptureProtocol, clopIntegration: ClopIntegration, previewOverlayService: OverlayWindowService) {
        self.settingsService = settingsService
        self.screenshotCapture = screenshotCapture
        self.clopIntegration = clopIntegration
        self.previewOverlayService = previewOverlayService
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
  
            let clopUrl = await clopIntegration.run(forContentOf: url)
            switch clopUrl {
            case .failure(let error):
                logger.error("Failed to send to clop \(error)")
            case .success(let clopResponse):
                url = clopResponse;
            }
            
            let finalUrl = url;
            await MainActor.run {
                guard let imageToShow = NSImage(contentsOf: finalUrl) else {
                    logger.error("Failed to create NSImage from URL: \(finalUrl)")
                    return
                }
                
                previewOverlayService.showOverlay(with: CapturedFile(
                    fileContent: finalUrl, type: .png, captureType: .screenshot
                ))
                logger.info("Showing overlay")
            }
            
            logger.info("URL is \(url)")
        }catch {
            logger.error("Failed to take snip \(error)")
        }
    }
    
}
