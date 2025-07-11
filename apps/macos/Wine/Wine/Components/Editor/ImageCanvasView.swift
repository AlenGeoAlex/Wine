//
//  ImageRender.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI

struct ImageCanvasView: View {
    @State var viewModel: ImageEditorViewModel
    let isInteractive: Bool

    var body: some View {
        ZStack {
            Group {
                if viewModel.editorOptions.backgroundType == .solid {
                    RoundedRectangle(cornerRadius: viewModel.editorOptions.cornerRadius)
                        .fill(Color(viewModel.editorOptions.backgroundColor).opacity(0.8))
                } else if viewModel.editorOptions.backgroundType == .gradient {
                    LinearGradient(gradient: viewModel.editorOptions.backgroundGradient, startPoint: .top, endPoint: .bottom)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: viewModel.editorOptions.cornerRadius))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

            if let image = viewModel.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: viewModel.editorOptions.imageCornerRadius))
                    .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
                    .padding(.horizontal, viewModel.editorOptions.horizontalPadding)
                    .padding(.vertical, viewModel.editorOptions.verticalPadding)

            }

            ForEach($viewModel.editorOptions.annotations) { $annotation in
                Text(annotation.text)
                    .font(.system(size: annotation.fontSize, weight: .bold))
                    .foregroundColor(annotation.color)
                    .offset(x: annotation.position.x, y: annotation.position.y)
                    .draggable(if: isInteractive, annotation: $annotation)
            }
            
            ForEach(viewModel.editorOptions.elements, id: \.id) { element in
                CanvasElementRenderer(element: element)
            }
            
            if let activeLine = viewModel.activeFreehandLine {
                CanvasElementRenderer(element: activeLine) 
            }
        }
    }
}

#Preview {
    ImageCanvasView(viewModel: ImageEditorViewModel(
        capture: Capture(type: .screenshot(ScreenshotOptions.defaultSettings()),
                         ext: "png",
                         filePath: URL(string: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1364&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!
                        )
    ), isInteractive: true)
}
