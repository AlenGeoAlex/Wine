//
//  PermissionHelpers.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import Foundation;
import AppKit;
import OSLog;
import UserNotifications;

class PermissionHelpers {
    
    static private let logger = Logger(subsystem: AppConstants.reversedDomain, category: "")
    
    /// Check accessibility permission
    static func checkAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        if !isTrusted {
            logger.warning("Please grant Accessibility access to this app in System Settings > Privacy > Accessibility.");
        }
    }
    
    @MainActor
    static func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                   if granted {
                       logger.info("Has notification permission")
                   } else if let error = error {
                       logger.error("Failed to get permission : \(error.localizedDescription)")
                   }
               }
    }
    
}
