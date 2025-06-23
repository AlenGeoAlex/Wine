//
//  UploadFileType.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

/// Possible Upload Sources
enum UploadSource : CaseIterable, Codable, Equatable, Identifiable, Hashable {
    
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
    
    var description : String {
        switch self {
        case .none:
            return "No cloud providers will be used. Image will saved to your clipboard"
        case .wineCloud:
            return "Uses wine's public cloud. (Coming soon)"
        case .wine(_):
            return "Connect to self-hosted wine backend hosted on your server"
        case .s3(_):
            return "Directly upload to your AWS S3 or S3 compatible provider"
        case .r2(_):
            return "Directly upload to your Cloudflare R3 provider"
        case .backblaze(_):
            return "Directly upload to your Backblaze B2 provider"
        case .sftp(_):
            return "Upload to your SFTP server"
        }
    }
    
    var wineSettings: WineServerSettings {
        get {
            guard case .wine(let settings) = self else { return WineServerSettings() }
            return settings
        }
        set {
            self = .wine(newValue)
        }
    }

    var s3Settings: S3Settings {
        get {
            guard case .s3(let settings) = self else { return S3Settings() }
            return settings
        }
        set {
            self = .s3(newValue)
        }
    }
    
    var r2Settings: R2Settings {
        get {
            guard case .r2(let settings) = self else { return R2Settings() }
            return settings
        }
        set {
            self = .r2(newValue)
        }
    }
    
    var backblazeSettings: BackblazeSettings {
        get {
            guard case .backblaze(let settings) = self else { return BackblazeSettings() }
            return settings
        }
        set {
            self = .backblaze(newValue)
        }
    }
    
    var sftpSettings: SFTPSettings {
        get {
            guard case .sftp(let settings) = self else { return SFTPSettings() }
            return settings
        }
        set {
            self = .sftp(newValue)
        }
    }
}
