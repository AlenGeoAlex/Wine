//
//  DateFormatter+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 06/07/25.
//
import AppKit

extension DateFormatter {
    static let iso8601withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        // The format MUST exactly match the string from your API
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // This is critical for ensuring the formatter doesn't get influenced
        // by the user's device settings (e.g., 12/24 hour time, calendar).
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // The 'Z' in your date string means UTC, so we set the timezone.
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }()
}
