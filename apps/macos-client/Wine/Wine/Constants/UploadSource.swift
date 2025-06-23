//
//  UploadFileType.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

/// Possible Upload Sources
enum UploadSource : CaseIterable, Codable, Equatable, Identifiable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: UploadSource, rhs: UploadSource) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let allCases: [UploadSource] = [
        .none,
        .wineCloud,
        .wine(WineServerSettings()),
        .s3(S3Settings()),
        .r2(R2Settings()),
        .backblaze(BackblazeSettings()),
        .sftp(SFTPSettings())
    ]
    
    static let allIds : [String] = allCases.map(\.self.id)
    
    static let allNames : [String] = allCases.map(\.self.name)
    
    case none
    case wineCloud
    case wine(WineServerSettings)
    case s3(S3Settings)
    case r2(R2Settings)
    case backblaze(BackblazeSettings)
    case sftp(SFTPSettings)
    
    var id: String {
        switch self {
        case .none:
            return "none"
        case .wineCloud:
            return "wineCloud"
        case .wine(_):
            return "wine"
        case .s3(_):
            return "s3"
        case .r2(_):
            return "r2"
        case .backblaze(_):
            return "backblaze"
        case .sftp(_):
            return "sftp"
        }
    }
    
    var name: String {
        switch self {
        case .none:
            return "None"
        case .wineCloud:
            return "Wine Cloud"
        case .wine(_):
            return "Selfhosted Wine"
        case .s3(_):
            return "S3 API"
            case .r2(_):
            return "Cloudflare R2"
        case .backblaze(_):
            return "Backblaze B2"
        case .sftp(_):
            return "SFTP"
        }
    }
    
}
