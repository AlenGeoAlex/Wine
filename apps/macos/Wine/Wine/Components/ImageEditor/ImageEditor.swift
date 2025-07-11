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
                .frame(minWidth: 400, idealWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
            
            ZStack {
                ImageCanvasView(viewModel: viewModel, isInteractive: true)
                    .frame(minWidth: 520, maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(viewModel.scale * gestureScale)
                    .offset(viewModel.offset + gestureOffset)
                    .clipped()
                    .onHover { hovering in
                        self.viewModel.isHoveringOverImagePort = hovering
                    }
                    .gesture(
                        TapGesture(count: 2).onEnded {
                            viewModel.resetZoomAndPan()
                        }
                        .simultaneously(with: TapGesture(count: 1).onEnded {
                            print("Tap")
                        })
                    )
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




#Preview {
    ImageEditor(for: Capture.preview())

}

