//
//  TextAnnotations.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import SwiftUI
import AppKit
import Foundation

struct TextAnnotation: CanvasElement {
    let id = UUID()
    var text: String
    var position: CGPoint
    var color: Color = .white
    var fontSize: CGFloat = 24.0
    var isSelected: Bool = false
}
