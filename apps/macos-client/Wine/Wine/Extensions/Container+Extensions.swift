//
//  ContainerExtensions.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import Foundation
import FactoryKit

extension Container {
    
    var settingsService: Factory<SettingsService> {
        self { @MainActor in SettingsService() }
            .singleton
    }
    
    var imageCaptureProtocol : Factory<ImageCaptureProtocol> {
        Factory(self){
            SCImageCapture();
        }.singleton
    }
    
    @available(macOS 15.0, *)
    var scVideoCapture : Factory<SCVideoCapture> {
        Factory(self){
            SCVideoCapture(
                notificationService: self.notificationService.resolve()
            )
        }
    }
    
    var screenshotOrchestra : Factory<AppOrchestra> {
        if #available(macOS 15.0, *) {
            Factory(self) {
                AppOrchestra(
                    settingsService: self.settingsService.resolve(),
                    screenshotCapture: self.imageCaptureProtocol.resolve(),
                )
            }.singleton
        }else{
            Factory(self) {
                AppOrchestra(
                    settingsService: self.settingsService.resolve(),
                    screenshotCapture: self.imageCaptureProtocol.resolve(),
                )
            }.singleton
        }
    }
    
    var notificationService : Factory<NotificationService> {
        Factory(self) {
            NotificationService()
        }.singleton
    }
    
}

