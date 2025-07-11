//
//  CaptureOptions.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//
import Foundation
import AppKit
import Defaults

enum CaptureType : Identifiable, Equatable {
    case screenrecord(ScreenRecordOptions)
    case screenshot(ScreenshotOptions)
    
    var id : String {
        switch self {
        case .screenrecord:
            return "screenrecord"
        case .screenshot:
            return "screenshot"
        }
    }
    
    static func == (lhs: CaptureType, rhs: CaptureType) -> Bool {
        switch (lhs, rhs) {
        case (.screenrecord, .screenrecord):
            return true
        case (.screenshot, .screenshot):
            return true
        default:
            return false
        }
    }
    
    var filePrefix : String {
        switch self {
        case .screenrecord:
            return "ScreenCapture"
        case .screenshot:
            return "ScreenShot"
        }
    }
    
    func isScreenshot() -> Bool {
        switch self {
        case .screenshot(_):
            return true
        default:
            return false
        }
    }
}

class ScreenshotOptions  {
    
    let format: ScreenshotFormat;
    
    init(format: ScreenshotFormat = .png){
        self.format = format
    }
    
    enum ScreenshotFormat : String, Identifiable {
        case png = "png"
        case jpeg = "jpg"
        
        var id: String {
            return self.rawValue
        }
    }
    
    static func defaultSettings() -> ScreenshotOptions {
        return ScreenshotOptions()
    }
    
}

class ScreenRecordOptions {
    
}
