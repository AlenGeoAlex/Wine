//
//  CaptureType.swift
//  Wine
//
//  Created by Alen Alex on 26/06/25.
//
enum CaptureType : Identifiable, Equatable, Hashable, CaseIterable {
    
    var id: String {
        switch self {
        case .screenshot:
            return "screenshot"
        case .video:
            return "video"
        }
    }
    
    case screenshot
    case video
}
