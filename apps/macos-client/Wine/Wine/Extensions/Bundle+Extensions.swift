//
//  Bundle+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import Foundation

public extension Bundle {
    /// The app's user-facing version string (e.g., "1.2.3").
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    /// The app's build number string (e.g., "154").
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
