//
//  ImageRender.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI

struct ImageCanvasView: View {
    @State var viewModel: SharedImageEditorViewModel
    let isInteractive: Bool

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                CanvasContent(viewModel: viewModel, isInteractive: isInteractive)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay {
                        if viewModel.isCropping {
                            CropView(cropRect: $viewModel.cropRect, canvasSize: geometry.size)
                        }
                    }
                    .onAppear {
                        self.viewModel.canvasSize = geometry.size
                        print("Update canvas size \(geometry.size.width) x \(geometry.size.height)")
                        if viewModel.cropRect == .zero {
                            viewModel.cropRect = CGRect(origin: .zero, size: geometry.size)
                        }
                    }
                    .onChange(of: geometry.size) { (_, newSize) in
                        self.viewModel.canvasSize = newSize
                    }
            }
            
            // Display the final result if it exists
            if let result = viewModel.croppedImage {
                Divider()
                Text("Cropped Result").padding(.top)
                Image(nsImage: result)
                    .resizable().scaledToFit().padding()
            }
            
        }
    }
}

#Preview {
    ImageCanvasView(viewModel: SharedImageEditorViewModel.preview(), isInteractive: true)
}

struct EditorControls: View {
    @Binding var isCropping: Bool
    var cropAction: () -> Void

    var body: some View {
        HStack {
            Button(isCropping ? "Cancel" : "Crop") {
                isCropping.toggle()
            }
            .keyboardShortcut(isCropping ? .cancelAction : .defaultAction)
            
            if isCropping {
                Spacer()
                Button("Apply") {
                    cropAction()
                    isCropping = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}
