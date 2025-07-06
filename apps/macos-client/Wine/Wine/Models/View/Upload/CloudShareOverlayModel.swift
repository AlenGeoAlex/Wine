//
//  CloudShareOverlayModel.swift
//  Wine
//
//  Created by Alen Alex on 06/07/25.
//
struct CloudShareOverlayModel {
    var fileName: String = ""
    var expiration : Expiration = .oneDay
    var securePassword: String = ""
    var linkType: LinkType = .webpage
    var tags: String = ""
}
