//
//  CanvasBackgroundView.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//

import SwiftUI

struct CanvasBackgroundView: View {
    
    @State var viewModel: SharedImageEditorViewModel
    
    var body: some View {
        Group {
            if viewModel.editorOptions.backgroundType == .solid {
                RoundedRectangle(cornerRadius: viewModel.editorOptions.cornerRadius)
                    .fill(Color(viewModel.editorOptions.backgroundColor).opacity(0.8))
                    .edgesIgnoringSafeArea(.all)
            } else if viewModel.editorOptions.backgroundType == .gradient {
                LinearGradient(gradient: viewModel.editorOptions.backgroundGradient, startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
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
    }
}

#Preview {
    CanvasBackgroundView(viewModel: SharedImageEditorViewModel.preview())
}
