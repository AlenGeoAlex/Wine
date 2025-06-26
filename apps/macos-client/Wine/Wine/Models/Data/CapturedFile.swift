//
//  CapturedFile.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Foundation
struct CapturedFile  {
    let fileContent : URL
    let type : OutputFileType
    let captureType : CaptureType
    
    init(fileContent: URL, type: OutputFileType, captureType: CaptureType) {
        self.fileContent = fileContent
        self.type = type
        self.captureType = captureType
    }
}
