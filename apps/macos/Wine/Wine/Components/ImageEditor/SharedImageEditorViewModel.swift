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
    var canvasWidth: CGFloat = 600
    var canvasHeight: CGFloat = 500
    var canvasCenter: CGPoint = .zero
    let capture: Capture;
    var editorOptions: EditorOptions = .init();
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var currentTool: DrawingTool = .select
    var activeFreehandLine: FreehandLine?
    var isHoveringOverImagePort: Bool = false
    var zoomingMonitor: Any?
    var keyboardMonitor: Any?
    var isCropping: Bool = false
    var cropRect: CGRect = .zero
    var croppedImage: NSImage?
    var canvasSize: CGSize = .zero
    private var hasPerformedInitialCentering = false
    var centerImageTask: Task<Void, Never>?

    
    init(capture: Capture) {
        self.capture = capture
        self.addImage(for: capture, at: canvasCenter)
        var image = editorOptions.elements.filter({$0 is ImageElement}).first
        image?.isSelected = true;
    }
    
    func addImage(for capture: Capture, at position: CGPoint?) {
        if let image = NSImage(contentsOf: capture.filePath) {
            let imageElement = ImageElement(id: capture.id, image: image)
            editorOptions.elements.append(imageElement)
            selectElement(imageElement)
        }
        captures[capture.id] = capture
        recalculateCanvasSize()
    }
    
    func removeImage(at offsets: IndexSet) {
        Task { @MainActor in
            editorOptions.elements.remove(atOffsets: offsets)
            recalculateCanvasSize()
        }
    }
    
    func remove(forKey: UUID){
        Task { @MainActor in
            editorOptions.elements.removeAll { $0.id == forKey }
        }
    }
    
    func addElement(_ element: any CanvasElement) {
        editorOptions.elements.append(element)
        self.selectElement(element)
    }
    
    func handleCanvasTap(at location: CGPoint) {
        switch currentTool {
            
        case .select:
            deselectAllElements()
            
        case .text:
            let newText = TextAnnotation(text: "New Text", position: location)
            addElement(newText)
            currentTool = .select
            
        case .shape(let shapeType):
            let newShape = ShapeElement(position: location, shapeType: shapeType, size: CGSize(width: 100, height: 100), color: .orange)
            addElement(newShape)
            currentTool = .select
            
        case .freehand:

            break
        }
    }
    
    // Temporary work around, its a very bad solution to center the image
    @MainActor
    func performInitialCentering(in size: CGSize) {
        guard !hasPerformedInitialCentering, size != .zero else { return }
        if let index = editorOptions.elements.firstIndex(where: { $0.id == self.capture.id }) {
            let isDirty = editorOptions.elements[index].isDirty
            if isDirty {
                hasPerformedInitialCentering = true
                return;
            }
            
            editorOptions.elements[index].position = NSPoint(x: size.width / 2, y: size.height / 2)
            editorOptions.elements[index].isSelected = true            
        }
    }
    
    
    private func recalculateCanvasSize() {
        guard let largestImage = editorOptions.images().max(by: {
            let area1 = $0.imageToRender.size.width * $0.imageToRender.size.height
            let area2 = $1.imageToRender.size.width * $1.imageToRender.size.height
            return area1 < area2
        }) else {
            withAnimation(.spring) {
                self.canvasWidth = 600
                self.canvasHeight = 500
            }
            return
        }

        let imageSize = largestImage.imageToRender.size
        let newWidth: CGFloat
        let newHeight: CGFloat
        
        if editorOptions.aspectRatio.ratio >= 1 {
            newWidth = min(700, max(500, imageSize.width * 1.2))
            newHeight = newWidth / editorOptions.aspectRatio.ratio
        } else {
            newHeight = min(800, max(500, imageSize.height * 1.2))
            newWidth = min(600, max(400, newHeight * editorOptions.aspectRatio.ratio))
        }
        
        withAnimation(.spring) {
            self.canvasWidth = newWidth
            self.canvasHeight = newHeight
        }
    }
    
    func resetZoomAndPan() {
        withAnimation(.interactiveSpring) {
            scale = 1.0
            offset = .zero
        }
    }
    
    func toggleCropping() {
        isCropping.toggle()
        if !isCropping {
            croppedImage = nil
        }
    }
    
    func selectElement(_ selectedElement: any CanvasElement) {
        deselectAllElements()
        
        if let index = editorOptions.elements.firstIndex(where: { $0.id == selectedElement.id }) {
            editorOptions.elements[index].isSelected = true
        }
    }
    
    func deselectAllElements() {
        for i in editorOptions.elements.indices {
            editorOptions.elements[i].isSelected = false
        }
    }
    
    func selectedElements() -> [any CanvasElement] {
        return editorOptions.elements.filter { $0.isSelected }
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
