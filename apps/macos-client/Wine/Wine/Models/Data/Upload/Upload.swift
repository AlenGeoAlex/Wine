//
//  File.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Foundation
class Upload {
    let fileName: String
    let fileSize : Decimal
    let fileUrl: URL
    
    init(fileName: String, fileSize: Decimal, fileUrl: URL) {
        self.fileName = fileName
        self.fileSize = fileSize
        self.fileUrl = fileUrl
    }
}
