//
//  ImageRender.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI
import UniformTypeIdentifiers

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
                            CropView(cropRect: viewModel.cropRect, canvasSize: geometry.size)
                        }
                    }
                    .onAppear {
                        self.viewModel.canvasSize = geometry.size
                        self.viewModel.canvasCenter = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                        print("Update canvas size \(geometry.size.width) x \(geometry.size.height)")
                        if viewModel.cropRect == .zero {
                            viewModel.cropRect = CGRect(origin: .zero, size: geometry.size)
                        }
                    }
                    .onChange(of: geometry.size) { (_, newSize) in
                        self.viewModel.canvasSize = newSize
                        self.viewModel.canvasCenter = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                    }
                    .onDrop(of: [UTType.fileURL, UTType.image], isTargeted: nil) { providers, location in
                        handleDrop(providers: providers, location: location)
                        return true
                    }
            }
    
        }
    }
    
    private func handleDrop(providers: [NSItemProvider], location: CGPoint) {
        guard let provider = providers.first else { return }

        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadObject(ofClass: NSURL.self) { (urlItem, error) in
                guard let url = urlItem as? URL else { return }
                
                let capture = Capture(
                    type: .screenshot(ScreenshotOptions.defaultSettings()), // Or determine type from file
                    ext: url.pathExtension,
                    filePath: url
                )
                
                DispatchQueue.main.async {
                    viewModel.addImage(for: capture, at: location)
                }
            }
            return
        }
        
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadObject(ofClass: NSImage.self) { (imageItem, error) in
                guard let image = imageItem as? NSImage else { return }
                

                let newCapture = Capture(
                    type: .screenshot(ScreenshotOptions.defaultSettings()),
                    ext: "png" // Default to PNG
                )

                let success = ImageHelper.saveImage(image, to: newCapture.filePath)
                
                if success {
                    DispatchQueue.main.async {
                        viewModel.addImage(for: newCapture, at: location)
                    }
                }
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
