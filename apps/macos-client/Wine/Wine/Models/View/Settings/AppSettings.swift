//
//  AppSettings.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import Foundation;
import AppKit;
import SwiftUI;

struct AppSettings : Codable, Equatable {
    
    var versionId = UUID();
    
    var integrateWithClop : Bool = false
    
    var hideWineWindows : Bool = true;
    
    var bindings : [BindableAction:KeyboardKey] = [:];
    
    static func createDefault() -> AppSettings {
        var settings = AppSettings()
        for action in BindableAction.allCases {
            settings.bindings[action] = .empty
        }
        return settings
    }
    
}
