//
//  AppConstants.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//
import Foundation
import AppKit

class AppConstants {
    
    static let reversedDomain = "me.alenalex.wine";
    
    static let appName = "Wine";
    
    public static let FolderStructureDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    class WindowConstants {
        static let RecorderWindowConstant = "WineRecorderWindow"
    }
    
    class Integrations {
        static let ClopBundleIdentifier = "com.lowtechguys.Clop";
    }
    
    class Settings {
        static let generalSettingsKey = "\(reversedDomain).appSettings";
        
        static let uploadTypeSetting = "\(reversedDomain).uploadTypeSetting";
        
        static let wineServerSetting = "\(reversedDomain).wineServer";
        
        static let s3ServerSetting = "\(reversedDomain).s3Server";
        
        static let r2ServerSetting = "\(reversedDomain).r2Server";
        
        static let backblazeServerSetting = "\(reversedDomain).backblazeServer";
        
        static let sftoServerSetting = "\(reversedDomain).sftoServer";
    }
}

