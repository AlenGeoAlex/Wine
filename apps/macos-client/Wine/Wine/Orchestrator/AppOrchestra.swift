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
    
    init(settingsService: SettingsService, screenshotCapture: ImageCaptureProtocol) {
        self.settingsService = settingsService
        self.screenshotCapture = screenshotCapture
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
  
            let useClop : Bool = await self.settingsService.appSettings.integrateWithClop;
            logger.info("Integrate with clop is \(useClop)")
            if(useClop){
                if(!AppHelpers.isAppRunning(appName: "Clop")){
                    logger.warning("Clopping is not running skipping")
                }
                
                let clopAvailable = ClopSDK.shared.waitForClopToBeAvailable(for: 0)
                if(clopAvailable){
                    let clopResponse = try ClopSDK.shared.optimise(url: url, aggressive: true)
                    let clopUrl = URL(string: clopResponse.path);
                    if(clopUrl == nil){
                        logger.warning("Failed to optimize image with clop")
                    }else{
                        url = clopUrl!
                        logger.info("Image has been optimized with clop to \(clopResponse.newBytes) from \(clopResponse.oldBytes)")
                    }
                }else{
                    logger.info("Clop is not available...")
                }
            }
            
            logger.info("URL is \(url)")
        }catch {
            logger.error("Failed to take snip \(error)")
        }
    }
    
}
