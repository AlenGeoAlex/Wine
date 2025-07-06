//
//  LinkType.swift
//  Wine
//
//  Created by Alen Alex on 06/07/25.
//

enum LinkType: String, CaseIterable, Identifiable {
    case webpage = "Webpage"
    case directLink = "Direct link"
    var id: Self { self }
}
