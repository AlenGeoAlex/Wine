//
//  ImageEditor.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import SwiftUI
import Combine
import FactoryKit
import AppKit
import Foundation
import OSLog
import UniformTypeIdentifiers

struct ImageEditor: View {
    
    @State private var viewModel: ImageEditorViewModel
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero
    
    init (for capture: Capture) {
        self.viewModel = ImageEditorViewModel(capture: capture)
    }
    
    var body: some View {
        HSplitView {
            ControlsView(viewModel: viewModel)
                .frame(minWidth: 220, idealWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
            
            ZStack {
                ImageCanvasView(viewModel: viewModel, isInteractive: true)
                    .frame(minWidth: 520, maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(viewModel.scale * gestureScale)
                    .offset(viewModel.offset + gestureOffset)
                    .clipped()
                    .onHover { hovering in
                        self.viewModel.isHoveringOverImagePort = hovering
                    }
                    .gesture(TapGesture(count: 2).onEnded {
                        viewModel.resetZoomAndPan()
                    })
                    .gesture(TapGesture(count: 1)
                        .onEnded {
                            print("Tap")
                        })
                    .onAppear(perform: {
                        if viewModel.zoomingMonitor == nil {
                            viewModel.zoomingMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel, handler: { event in
                                if self.viewModel.isHoveringOverImagePort == false { return event }
                                
                                let x = event.scrollingDeltaY/100
                                viewModel.scale += x
                                if viewModel.scale < 0.1 { viewModel.scale = 0.1 }
                                return event;
                            })
                        }
                    })
                    .onDisappear(perform: {
                        if viewModel.zoomingMonitor != nil {
                            NSEvent.removeMonitor(viewModel.zoomingMonitor!)
                            viewModel.zoomingMonitor = nil
                        }
                    })


                VStack {
                    HStack {
                        Spacer()
                        Button(action: viewModel.resetZoomAndPan) {
                            Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .padding()
                    }
                    Spacer()
                }
            }
            .clipped()
            .gesture(panGesture())
        }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gestureOffset) { latestValue, gestureState, _ in
                if viewModel.scale > 1.0 && self.viewModel.currentTool == .select {
                    gestureState = latestValue.translation
                }
            }
            .onEnded { finalValue in
                if viewModel.scale > 1.0 && self.viewModel.currentTool == .select {
                    viewModel.offset.width += finalValue.translation.width
                    viewModel.offset.height += finalValue.translation.height
                }
            }
    }
}

@Observable class ImageEditorViewModel {
    let capture: Capture;
    let image: NSImage?;
    var editorOptions: EditorOptions = .init();
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var currentTool: DrawingTool = .select
    var activeFreehandLine: FreehandLine?
    var isHoveringOverImagePort: Bool = false
    var zoomingMonitor: Any?
    

    
    init(capture: Capture) {
        self.capture = capture
        self.image = NSImage(contentsOf: capture.filePath)
    }
    
    func resetZoomAndPan() {
        withAnimation(.interactiveSpring) {
            scale = 1.0
            offset = .zero
        }
    }
    
    var calculatedCanvasWidth: CGFloat {
        if let image = image {
            if editorOptions.aspectRatio.ratio >= 1 {
                return min(700, max(500, image.size.width * 1.2))
            } else {
                return min(600, max(400, image.size.height * 1.2 * editorOptions.aspectRatio.ratio))
            }
        }
        return 600
    }
    
    var calculatedCanvasHeight: CGFloat {
        if let image = image {
            if editorOptions.aspectRatio.ratio >= 1 {
                return calculatedCanvasWidth / editorOptions.aspectRatio.ratio
            } else {
                return min(800, max(500, image.size.height * 1.2))
            }
        }
        return 500 // Default
    }
    
    /**
     * Returns the 3D rotation angle based on selected direction
     */
    func get3DRotationAngle() -> Angle {
        switch editorOptions.perspective3DDirection {
        case .topLeft, .top, .topRight:
            return .degrees(15)
        case .bottomLeft, .bottom, .bottomRight:
            return .degrees(-15)
        }
    }
    
    /**
     * Returns the 3D rotation axis based on selected direction
     */
    func get3DRotationAxis() -> (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch editorOptions.perspective3DDirection {
        case .topLeft:
            return (x: 1, y: 1, z: 0)
        case .top:
            return (x: 1, y: 0, z: 0)
        case .topRight:
            return (x: 1, y: -1, z: 0)
        case .bottomLeft:
            return (x: -1, y: 1, z: 0)
        case .bottom:
            return (x: -1, y: 0, z: 0)
        case .bottomRight:
            return (x: -1, y: -1, z: 0)
        }
    }
    
    /**
     * Returns the anchor point for rotation based on direction
     */
    func get3DRotationAnchor() -> UnitPoint {
        switch editorOptions.perspective3DDirection {
        case .topLeft:
            return .topLeading
        case .top:
            return .top
        case .topRight:
            return .topTrailing
        case .bottomLeft:
            return .bottomLeading
        case .bottom:
            return .bottom
        case .bottomRight:
            return .bottomTrailing
        }
    }
}


#Preview {
    ImageEditor(for: Capture(type: .screenshot(ScreenshotOptions.defaultSettings()),
                                 ext: "png",
                                 filePath: URL(string: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1364&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!
                                ))

}

