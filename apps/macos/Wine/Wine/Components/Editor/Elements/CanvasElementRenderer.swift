//
//  CanvasElementRenderer.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import AppKit
import SwiftUI

struct CanvasElementRenderer: View {
    let element: any CanvasElement

    var body: some View {
        if let textAnnotation = element as? TextAnnotation {
            Text(textAnnotation.text)
                .font(.system(size: textAnnotation.fontSize, weight: .bold))
                .foregroundColor(textAnnotation.color)
                .offset(x: textAnnotation.position.x, y: textAnnotation.position.y)

        } else if let shapeElement = element as? ShapeElement {
            shapeElement
        } else if let freehandLine = element as? FreehandLine {
            freehandLine
        }
    }
}
