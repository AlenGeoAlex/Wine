//
//  CanvasElementView.swift
//  Wine
//
//  Created by Alen Alex on 13/07/25.
//

import SwiftUI

struct CanvasElementView: View {
    @State var element: any CanvasElement
    let isInteractive: Bool
    let onSelect: () -> Void
    
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        elementContent
            .overlay {
                if isInteractive && element.isSelected {
                    let cornerRadius = (element as? ImageElement)?.cornerRadius ?? 8
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.blue, lineWidth: 2)
                        .padding(-6)
                }
            }
            .position(x: element.position.x, y: element.position.y)
            .offset(dragOffset)
            .onTapGesture {
                if isInteractive {
                    onSelect()
                }
            }
            .gesture(isInteractive ? dragGesture : nil)
    }

    @ViewBuilder
    private var elementContent: some View {
        if let imageElement = element as? ImageElement {
            ImageView(imageElement: imageElement, isInteractive: isInteractive)
                .fixedSize()
        } else if let textAnnotation = element as? TextAnnotation {
            Text(textAnnotation.text)
                .font(textAnnotation.font)
                .foregroundColor(textAnnotation.color)
                .padding(10)
                .background(Color.black.opacity(0.001))
                .fixedSize()
        } else if let shapeElement = element as? ShapeElement {
            render(shape: shapeElement)
        } else if let freehandLine = element as? FreehandLine {
            render(line: freehandLine)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                self.dragOffset = value.translation
            }
            .onEnded { value in
                element.position.x += value.translation.width
                element.position.y += value.translation.height
                self.dragOffset = .zero
            }
    }
    
    
    @ViewBuilder
    private func render(shape: ShapeElement) -> some View {
        switch shape.shapeType {
        case .rectangle:
            Rectangle()
                .stroke(shape.color, lineWidth: 5)
                .frame(width: shape.size.width, height: shape.size.height)
                .fixedSize()
        case .ellipse:
            Ellipse()
                .stroke(shape.color, lineWidth: 5)
                .frame(width: shape.size.width, height: shape.size.height)
                .fixedSize() 
        }
    }
    
    @ViewBuilder
    private func render(line: FreehandLine) -> some View {
        Path { path in
            guard line.points.count > 1 else { return }
            path.move(to: line.points.first!)
            path.addLines(line.points)
        }
        .stroke(line.color, style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
        .frame(width: line.points.map(\.x).max() ?? 0, height: line.points.map(\.y).max() ?? 0)

    }
}
