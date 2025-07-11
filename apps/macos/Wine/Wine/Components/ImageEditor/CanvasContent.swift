//
//  CanvasContent.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//

import SwiftUI

struct CanvasContent: View {
    
    @State var viewModel: SharedImageEditorViewModel
    let isInteractive: Bool
    
    var body: some View {
        ZStack {
            Group {
                if viewModel.editorOptions.backgroundType == .solid {
                    RoundedRectangle(cornerRadius: viewModel.editorOptions.cornerRadius)
                        .fill(Color(viewModel.editorOptions.backgroundColor).opacity(0.8))
                } else if viewModel.editorOptions.backgroundType == .gradient {
                    LinearGradient(gradient: viewModel.editorOptions.backgroundGradient, startPoint: .top, endPoint: .bottom)
                } else if viewModel.editorOptions.backgroundType == .image {
                    if let source = self.viewModel.editorOptions.backgroundImageUrl {
                        switch source {
                        case .preset(let path):
                            Image(path)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .blur(radius: self.viewModel.editorOptions.backgroundImageBlurRadius)

                        case .local(let name):
                            Image(nsImage: NSImage(contentsOf: URL(string: name)!)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .blur(radius: self.viewModel.editorOptions.backgroundImageBlurRadius)

                        case .remote(let url):
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .blur(radius: self.viewModel.editorOptions.backgroundImageBlurRadius)

                        }
                    } else {
                        Color.gray.opacity(0.2)
                    }
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
                    .overlay(
                        RoundedRectangle(cornerRadius: viewModel.editorOptions.imageCornerRadius)
                            .stroke(Color.red, lineWidth: 1) // Draws a stroke inside the shape
                    )
                    .padding(.horizontal, viewModel.editorOptions.horizontalPadding)

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
    CanvasContent(viewModel: SharedImageEditorViewModel.preview(), isInteractive: true)
}
