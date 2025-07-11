//
//  Container+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
import FactoryKit

extension Container {
    
    @MainActor
    var appState: Factory<WineAppState> {
        return Factory(self) { @MainActor in
            WineAppState()
        }.singleton
    }
    

    
    // MARK: Services
    var screenshotService: Factory<ScreenshotService> {
        return Factory(self) { ScreenshotService(container: self) }.singleton
    }
    
    var screenRecordService: Factory<ScreenRecordService> {
        return Factory(self) { ScreenRecordService(container: self) }.singleton
    }
    
    var panelService: Factory<PanelService> {
        return Factory(self) { PanelService(container: self) }.singleton
    }
    
    var windowService : Factory<WindowService> {
        return Factory(self) { WindowService() }.singleton
    }
}
