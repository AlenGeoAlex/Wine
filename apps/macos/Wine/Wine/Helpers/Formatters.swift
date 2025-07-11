//
//  Formatters.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//
import Foundation
import AppKit

class Formatters {
    /// Returns the formatter to convert to YYYY-MM-DD
    public static let justYMDDate : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    public static let isoDate: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
