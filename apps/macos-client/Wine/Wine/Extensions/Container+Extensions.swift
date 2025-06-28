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
    var scVideoCapture: Factory<SCVideoCapture> {
        self { SCVideoCapture(notificationService: self.notificationService()) }
            .singleton
    }
    
    var screenshotOrchestra : Factory<AppOrchestra> {
        Factory(self) {
            AppOrchestra(
                container: self
            )
        }.singleton
    }
    
    var notificationService : Factory<NotificationService> {
        Factory(self) {
            NotificationService()
        }.singleton
    }
    
    var clopIntegration : Factory<ClopIntegration> {
        Factory(self) {
            ClopIntegration(
                settingsService: self.settingsService.resolve()
            )
        }.singleton
    }
    
    var previewOverlayService : Factory<OverlayWindowService> {
        Factory(self) {
            OverlayWindowService()
        }.singleton
    }
    
    var fileUploadApi : Factory<FileUploadApiService> {
        Factory(self) {
            FileUploadApiService()
        }.singleton
    }
    
}

