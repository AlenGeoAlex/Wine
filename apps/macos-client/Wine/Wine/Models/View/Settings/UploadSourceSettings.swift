//
//  UploadSourceSettings.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import Foundation;

struct WineServerSettings : Codable, Equatable, Hashable {
    
    init(){
        self.serverAddress = URL(string: "http://localhost:8080")!
        self.secureToken = ""
    }
    
    var serverAddress: URL
    var secureToken: String
}

struct S3Settings : Codable, Equatable, Hashable {
    
    init(){
        self.bucketName = ""
        self.accessKey = ""
        self.secretKey = ""
        self.endpoint = ""
    }
    
    var bucketName: String
    var region: String = "us-east-1"
    var accessKey: String
    var secretKey: String
    var endpoint: String
    var customDomain : String?
    var usePathStyle : Bool = false
    var usePresignedUrl : Bool = false
}

struct R2Settings : Codable, Equatable, Hashable {
    
    init(){
        self.accessKey = ""
        self.secretKey = ""
        self.bucketName = ""
        self.accountId = ""
    }
    
    var accountId: String
    var accessKey: String
    var secretKey: String
    var bucketName: String
}

struct SFTPSettings : Codable, Equatable, Hashable {
    
    init(){
        self.host = ""
        self.username = ""
        self.password = ""
    }
    
    var host: String
    var username: String
    var password: String
    var port: Int = 21
    var rootPath: String = "/"
}

struct BackblazeSettings : Codable, Equatable, Hashable {
    
    init(){
        self.bucketName = ""
        self.accessKey = ""
        self.secretKey = ""
        self.endpoint = ""
    }
    
    var bucketName: String
    var accessKey: String
    var secretKey: String
    var endpoint: String
}
