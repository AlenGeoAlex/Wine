//
//  Expiration.swift
//  Wine
//
//  Created by Alen Alex on 04/07/25.
//
enum Expiration: String, CaseIterable, Identifiable {
    case oneHour = "1 hour"
    case sixHours = "6 hours"
    case oneDay = "1 day"
    case oneWeek = "1 week"
    case never = "Never"
    var id: Self { self }
}
