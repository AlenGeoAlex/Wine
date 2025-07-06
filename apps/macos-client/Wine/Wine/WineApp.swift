//
//  WineApp.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import SwiftUI;
import OSLog;
import FactoryKit

@main
struct WineApp: App {
    @NSApplicationDelegateAdaptor(WineAppDelegate.self) var appDelegate
    
    private let logger = Logger(subsystem: AppConstants.reversedDomain, category: "WineApp");
    private let cgTapListener : GlobalCGTap;
    private let recorderWindowID = "recorder-controls"
    
    init(){
        self.cgTapListener = GlobalCGTap(container: Container.shared);
        PermissionHelpers.requestNotificationAuthorization();
    }
    
    var body: some Scene {
        MenuBarViewOS15()
        
        if #available(macOS 15.0, *) {
            Window("Recorder Configuration", id: AppConstants.WindowConstants.RecorderWindowConstant) {
                ScreenCaptureView()
            }
            .windowResizability(.contentSize)
            .windowStyle(.hiddenTitleBar)
        }
    }
}


