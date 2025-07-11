//
//  UUID+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//
import Foundation

extension UUID {
    
    func normalized() -> String {
        return self.uuidString.replacingOccurrences(of: "-", with: "")
            .lowercased(with: .current)
    }
    
}
