//
//  FileHelpers.swift
//  Wine
//
//  Created by Alen Alex on 26/06/25.
//
import Foundation
import AppKit

class FileHelpers {
    
    public static func delete(file: URL) -> Result<Bool, Error> {
        do {
            try FileManager.default.removeItem(at: file)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
}
