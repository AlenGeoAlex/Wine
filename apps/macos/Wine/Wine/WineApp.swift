//
//  WineApp.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import SwiftUI
import FactoryKit

@main
struct WineApp: App {
    
    @NSApplicationDelegateAdaptor(WineAppDelegate.self) var appDelegate
    
    init(){
        // Initialie it from the main actor
        let _ = Container.shared.appState.resolve();
    }
    
    var body: some Scene {
        MenuBarExtra("Wine", systemImage: WineConstants.appIcon) {
            MenuBarComponent()
        }
    
    }
}
