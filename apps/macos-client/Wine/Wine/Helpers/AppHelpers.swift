//
//  AppHelpers.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//
import AppKit;

public class AppHelpers {
    
    /// Check whether an app with provided bundleId has been installed or not
    public static func isAppInstalled(identifier: String) -> Bool {
        guard let _ = NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier) else {
            return false;
        }
        
        return true;
    }
    
    /// Checks whether an app is running or not
    public static func isAppRunning(appName: String) -> Bool {
        let apps = NSWorkspace.shared.runningApplications
        return apps.contains { $0.localizedName?.lowercased() == appName.lowercased() }
    }
    
}
