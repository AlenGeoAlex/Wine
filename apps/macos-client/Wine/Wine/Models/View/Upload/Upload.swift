//
//  File.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Foundation
struct Upload : Identifiable, Equatable {
    let id : String;
    let fileName: String
    let fileSize : Decimal
    let fileUrl: URL
    let pausable: Bool
    
    
    init(id : String, fileName: String, fileSize: Decimal, fileUrl: URL, pausable: Bool = false) {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
        self.fileUrl = fileUrl
        self.pausable = pausable
    }
}
