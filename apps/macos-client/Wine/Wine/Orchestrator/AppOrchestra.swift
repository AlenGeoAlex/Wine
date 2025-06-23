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

class AppOrchestra : ObservableObject {
    
    private let logger : Logger =  Logger(subsystem: AppConstants.reversedDomain, category: "ScreenshotOrchestra")
    
    private let settingsService : SettingsService;
    private let screenshotCapture : ImageCaptureProtocol;
    
    init(settingsService: SettingsService, screenshotCapture: ImageCaptureProtocol) {
        self.settingsService = settingsService
        self.screenshotCapture = screenshotCapture
    }
    
    func takeSnip() async -> Void {
        do {
            let image = try await self.screenshotCapture.captureImageWithSelection();
            let url = try image.get();
            
            logger.info("File has been saved to \(url)")
            guard let nsImage = NSImage(contentsOf: url) else {
                logger.error("Failed to take snip")
                return;
            }
            
            let clipboardUrl = try ClipboardHelper.saveImageToTempFile(nsImage)
            logger.info("URL is \(clipboardUrl)")
        }catch {
            logger.error("Failed to take snip \(error)")
        }
    }
    
}
