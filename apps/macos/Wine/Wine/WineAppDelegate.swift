//
//  WineAppDelegate.swift
//  Wine
//
//  Created by Alen Alex on 26/06/25.
//

import Foundation
import AppKit
import OSLog

class WineAppDelegate : NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        Logger.common.log("Application has been initialized")
    }
    
}
