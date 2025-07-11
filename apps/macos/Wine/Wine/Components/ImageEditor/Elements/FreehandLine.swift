//
//  FreehandLine.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import AppKit
import SwiftUI

struct FreehandLine: CanvasElement, View {
    let id = UUID()
    var position: CGPoint = .zero
    var isSelected: Bool = false
    
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    
    var body: some View {
        Path { path in
            guard points.count > 1 else { return }
            path.move(to: points.first!)
            path.addLines(points)
        }
        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
    }
}
