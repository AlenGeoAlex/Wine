//
//  Default+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//
import Defaults
import AppKit

extension Defaults.Keys {
    static let cloudProvider = Key<String>("cloudProvider", default: CloudProviders.none.id)
    static let previewPanelDuration = Key<Double>("previewPanelDuration", default: 10.0)
    static let previewPanelPosition = Key<ViewPosition>("previewPanelPosition", default: .bottomLeft)
    static let preventAutoClosePreviewOnActivity = Key<Bool>("preventAutoClosePreviewOnActivity", default: true)
}
