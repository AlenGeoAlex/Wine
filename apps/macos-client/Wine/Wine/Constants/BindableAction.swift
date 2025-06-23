//
//  BindableAction.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//
enum BindableAction : String, Identifiable, CaseIterable, Equatable, Hashable, Codable {
    var id: String { rawValue }
    
    case quickSnip;
    case snip;
    case quickScreenRecord;
    case screenRecord;
    
    var name: String {
        switch self {
        case .quickSnip:
            return "Quick Snip"
        case .snip:
            return "Snip"
        case .quickScreenRecord:
            return "Quick Screen Record"
        case .screenRecord:
            return "Screen Record"
        }
    }
    
    var settingIcon : String {
        switch self {
        case .quickSnip:
            return "square.and.arrow.up.on.square"
        case .snip:
            return "square.and.arrow.up.on.square"
        case .quickScreenRecord:
            return "square.and.arrow.up.on.square"
        case .screenRecord:
            return "square.and.arrow.up.on.square"
        }
    }
    
    var settingDescription : String {
        switch self {
        case .quickSnip:
            return "Takes a snip and directly upload it to the cloud or clipboard based on setting"
        case .snip:
            return "Takes a snip and open the previewer window"
        case .quickScreenRecord:
            return "Records a screen recording and directly upload it to the cloud or clipboard based on setting"
        case .screenRecord:
            return "Records a screen recording and open the previewer window"
        }
    }
}
