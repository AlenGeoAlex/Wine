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
    
    @State private var viewModel: SharedImageEditorViewModel
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero
    
    init (for capture: Capture) {
        self.viewModel = SharedImageEditorViewModel(capture: capture)
    }
    
    var body: some View {
        HSplitView {
            ControlsView(viewModel: viewModel)
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 400) // Removed maxHeight, let it be flexible


            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        viewModel.deselectAllElements()
                    }

                GeometryReader { geometry in
                    ImageCanvasView(viewModel: viewModel, isInteractive: true)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onChange(of: geometry.size) { _, newSize in
                            viewModel.canvasSize = newSize
                            viewModel.offset = .zero
                            if !viewModel.isCropping {
                                viewModel.cropRect = CGRect(origin: .zero, size: newSize)
                            }
                        }
                        .onAppear {
                            viewModel.canvasSize = geometry.size
                            if viewModel.cropRect == .zero {
                                viewModel.cropRect = CGRect(origin: .zero, size: geometry.size)
                            }
                        }
                }
                .scaleEffect(viewModel.scale * gestureScale)
                .offset(viewModel.offset + gestureOffset)
                .clipped()

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
            .frame(minWidth: 520, maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .onHover { hovering in
                self.viewModel.isHoveringOverImagePort = hovering
            }
            .gesture(panGesture())
            .simultaneousGesture(magnificationGesture())
            .simultaneousGesture(doubleTapToResetGesture())
            
            .onAppear(perform: {
                if viewModel.zoomingMonitor == nil {
                    viewModel.zoomingMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel, handler: monitorScrollWheel)
                }
                
                if viewModel.keyboardMonitor == nil {
                    viewModel.keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown], handler: keyboardMonitor)
                }
            })
            .onDisappear(perform: {
                if let monitor = viewModel.zoomingMonitor {
                    NSEvent.removeMonitor(monitor)
                    viewModel.zoomingMonitor = nil
                }
                
                if let keyboardMonitor = viewModel.keyboardMonitor {
                    NSEvent.removeMonitor(keyboardMonitor)
                    viewModel.keyboardMonitor = nil
                }
            })
        }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($gestureOffset) { latestValue, gestureState, _ in
                let isPanning = NSEvent.modifierFlags.contains(.command) || viewModel.currentTool != .select
                if viewModel.scale > 1.0 && isPanning {
                    gestureState = latestValue.translation
                }
            }
            .onEnded { finalValue in
                let isPanning = NSEvent.modifierFlags.contains(.command) || viewModel.currentTool != .select
                if viewModel.scale > 1.0 && isPanning {
                    viewModel.offset.width += finalValue.translation.width
                    viewModel.offset.height += finalValue.translation.height
                }
            }
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { latestGestureScale, gestureState, _ in
                gestureState = latestGestureScale
            }
            .onEnded { finalGestureScale in
                viewModel.scale *= finalGestureScale
            }
    }
    
    private func doubleTapToResetGesture() -> some Gesture {
        TapGesture(count: 2).onEnded {
            viewModel.resetZoomAndPan()
        }
    }
    
    func selectedElements() -> [any CanvasElement] {
        return viewModel.selectedElements();
    }
    
    private func deleteSelectedElements() {
        self.selectedElements().forEach { element in
            self.viewModel.remove(forKey: element.id)
        }
    }
    
    private func keyboardMonitor(event: NSEvent) -> NSEvent? {
        guard event.type == .keyDown else {
            return event
        }
        let isDeleteKey = (event.keyCode == 51 || event.keyCode == 117)

        if isDeleteKey {
            if let firstResponder = NSApp.keyWindow?.firstResponder, firstResponder.isKind(of: NSText.self) {
                return event
            }

            DispatchQueue.main.async {
                self.deleteSelectedElements()
            }
            
            return nil
        }
        
        return event
    }

    private func monitorScrollWheel(event: NSEvent) -> NSEvent? {
        // Zoom the entire area
        if self.viewModel.isHoveringOverImagePort == true && !event.modifierFlags.contains(.command) {
            let delta = event.scrollingDeltaY / 100
            viewModel.scale = max(0.2, viewModel.scale + delta)
            return nil;
        }
        
        // Zoom the selected elements (Images/Text only for now)
        self.selectedElements().forEach { element in
            let delta = event.scrollingDeltaY / 50.0

            if element is ImageElement {
                let imageElement = (element as? ImageElement)!
                let newScale = imageElement.scale + delta
                imageElement.scale =  max(0.1, newScale);
                return;
            }
            
            if(element is TextAnnotation) {
                let textElement = (element as? TextAnnotation)!
                textElement.fontSize += CGFloat(delta)
                return;
            }
        }
        
        return event;
    }
}




#Preview {
    ImageEditor(for: Capture.preview())

}

