//
//  ClopIntegration.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//
import Foundation
import AppKit
import OSLog
import ClopSDK

class ClopIntegration {
    
    let settingsService : SettingsService
    
    init(settingsService: SettingsService) {
        self.settingsService = settingsService
    }
    
    let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "ClopIntegration")
    
    @MainActor
    func run(forContentOf url : URL) -> Result<URL, ClopIntegrationError> {
        do {
            if(self.settingsService.appSettings.integrateWithClop){
                logger.info("Clop integration is disabled, returning original url")
                return .success(url);
            }
            
            if(!AppHelpers.isAppRunning(appName: "Clop")){
                logger.warning("Clopping is not running skipping")
                return .failure(.notAccessable)
            }
            
            let clopAvailable = ClopSDK.shared.waitForClopToBeAvailable(for: 0)
            if(clopAvailable){
                let clopResponse = try ClopSDK.shared.optimise(url: url, aggressive: true)
                let clopUrl = URL(string: clopResponse.path);
                if(clopUrl == nil){
                    logger.warning("Failed to optimize image with clop")
                    return .failure(.unknownError)
                }else{
                    logger.info("Image has been optimized with clop to \(clopResponse.newBytes) from \(clopResponse.oldBytes)")
                    return .success(clopUrl!)
                }
            }else{
                logger.info("Clop is not available...")
            }
            
            return .failure(.quotaExceeded)
        }catch {
            logger.error("Failed to run clop integration \(error)")
            return .failure(.unknownError)
        }
    }
    
}

enum ClopIntegrationError : String, Error, Identifiable {
        
    case quotaExceeded = "QuotaExceeded"
    case notAccessable = "NotAccessable"
    case unknownError = "UnknownError"
    
    var id : String {
        self.rawValue
    }
}
