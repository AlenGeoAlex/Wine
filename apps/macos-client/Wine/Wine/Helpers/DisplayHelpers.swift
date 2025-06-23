//
//  DisplayHelpers.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//
import Foundation
import AppKit
import ScreenCaptureKit

class DisplayHelpers {
    
    static func getDisplayById(by id: CGDirectDisplayID) async -> SCDisplay? {
        guard let content = await getSharableWindows() else { return nil }
        return content.displays.first { $0.displayID == id }
    }
    
    static func getSharableWindows() async -> SCShareableContent? {
        guard let content = try? await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true) else { return nil }
        return content
    }
}
