//
//  WineConstants.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//
import Foundation

class WineConstants {
    static let appName = "Wine"
    
    static let appURL : String = "https://github.com/AlenGeoAlex/Wine"
    
    static let appIcon: String = "recordingtape.circle.fill"
    
    static let bundleIdentifier : String = Bundle.main.bundleIdentifier ?? "me.alenalex.\(appName)";

    static let buildNumber : String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A";
    
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A";
}
