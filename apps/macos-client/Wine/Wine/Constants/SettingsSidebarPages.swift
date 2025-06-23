//
//  SettingsSidebarPages.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

enum SettingsSidebarPages : String, Identifiable, Hashable, CaseIterable {
    case general = "General"
    case keybinds = "Keybinds"
    case cloudSharing = "Cloud Sharing"
    case about = "About"
    
    var id : String {return self.rawValue}
    
    var description: String {
        switch self {
        case .general:
            return "General settings of Wine"
        case .cloudSharing:
            return "Control and configure how images are shared through cloud"
        case .keybinds:
            return "Global keybinding settings"
        case .about:
            return "About Wine"
        }
    }
    
    var icon: String {
        switch self {
        case .general:
            return "gear"
        case .cloudSharing:
            return "cloud.fill"
        case .keybinds:
            return "keyboard"
        case .about:
            return "info.circle"
        }
    }
}
