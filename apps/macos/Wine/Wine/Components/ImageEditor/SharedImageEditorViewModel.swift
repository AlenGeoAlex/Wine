//
//  SharedImageEditorViewModel.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import AppKit
import SwiftUI
import Combine
import Foundation
import OSLog

@Observable class SharedImageEditorViewModel {
    
    private let logger : Logger = Logger.create();
    
    public static func preview() -> SharedImageEditorViewModel {
        return .init(capture: Capture.preview())
    }
    
    var captures : [UUID:Capture] = [:];
    
    let capture: Capture;
    let image: NSImage?;
    var editorOptions: EditorOptions = .init();
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var currentTool: DrawingTool = .select
    var activeFreehandLine: FreehandLine?
    var isHoveringOverImagePort: Bool = false
    var zoomingMonitor: Any?
    var isCropping: Bool = false
    var cropRect: CGRect = .zero
    var croppedImage: NSImage?
    var canvasSize: CGSize = .zero
    

    
    init(capture: Capture) {
        self.capture = capture
        self.image = NSImage(contentsOf: capture.filePath)
        self.captures[capture.id] = capture // TODO MODEL PROPERLY TOMORROW
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
    
    func toggleCropping() {
        isCropping.toggle()
        if !isCropping {
            croppedImage = nil
        }
    }
    
    @MainActor
    func applyCrop<V: View>(contentToRender: V) {
        guard canvasSize.width > 0 && canvasSize.height > 0 else {
            logger.warning("Canvas size is zero. Aborting render.")
            return
        }

        guard let window = NSApplication.shared.windows.first(where: { $0.isVisible }) else {
            logger.warning("Could not find an active window.")
            return
        }
        let scale = window.backingScaleFactor
        logger.trace("Screen scale is \(scale)x.")
        
        let result = renderAndCrop(
            content: contentToRender.frame(width: canvasSize.width, height: canvasSize.height),
            in: CGRect(origin: .zero, size: canvasSize),
            cropRect: self.cropRect,
            scale: scale
        )
        
        if let image = result {
            logger.info("Image was rendered and cropped. Final size: \(image.size.width)x\(image.size.height)")
            self.croppedImage = image
        } else {
            logger.error("The 'renderAndCrop' helper function returned nil.")
        }
        
        self.isCropping = false
    }
    
    @MainActor
    private func renderAndCrop<V: View>(
        content: V,
        in frame: CGRect,
        cropRect: CGRect,
        scale: CGFloat
    ) -> NSImage? {
        let renderer = ImageRenderer(content: content)
        renderer.scale = scale
        
        guard let renderedImage = renderer.nsImage else { return nil }
        
        let pixelCropRect = CGRect(
            x: cropRect.origin.x * scale,
            y: cropRect.origin.y * scale,
            width: cropRect.size.width * scale,
            height: cropRect.size.height * scale
        )
        
        let flippedY = renderedImage.size.height - pixelCropRect.origin.y - pixelCropRect.size.height
        let cgCropRect = CGRect(x: pixelCropRect.origin.x, y: flippedY, width: pixelCropRect.width, height: pixelCropRect.height)

        guard let cgImage = renderedImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let croppedCGImage = cgImage.cropping(to: cgCropRect)
        else { return nil }

        return NSImage(cgImage: croppedCGImage, size: cgCropRect.size)
    }
    
}
