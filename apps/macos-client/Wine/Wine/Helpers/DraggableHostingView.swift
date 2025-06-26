//
//  DraggableHostingView.swift
//  Wine
//
//  Created by Alen Alex on 26/06/25.
//

import Foundation
import OSLog
import SwiftUI
import AppKit

/// A custom NSHostingView that intercepts mouse drags over its entire area
/// to initiate a file drag-and-drop session.
class DraggableHostingView<Content: View>: NSHostingView<Content>, NSPasteboardItemDataProvider {

    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "DraggableHostingView")
    
    var fileToDrag: CapturedFile?
    
    private let dragSource = FileDragSource()

    /// Custom initializer to accept the file URL that needs to be dragged.
    init(rootView: Content, fileToDrag: CapturedFile) {
        self.fileToDrag = fileToDrag
        super.init(rootView: rootView)
    }

    @MainActor required dynamic init(rootView: Content) {
        self.fileToDrag = nil
        super.init(rootView: rootView)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drag Initiation

    override func mouseDragged(with event: NSEvent) {
        guard let file = fileToDrag else {
            super.mouseDragged(with: event)
            logger.warning("No file has been detected, so no drag")
            return
        }

        let pasteboardItem = NSPasteboardItem()

        if file.captureType == .screenshot, let pngData = try? Data(contentsOf: file.fileContent) {
            pasteboardItem.setData(pngData, forType: .png)
        }
        
        pasteboardItem.setDataProvider(self, forTypes: [.fileURL])

        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(self.bounds, contents: self.rootView.snapshot())

        logger.info("Dragging session has been started")
        beginDraggingSession(with: [draggingItem], event: event, source: self.dragSource)
    }

    // MARK: - NSPasteboardItemDataProvider

    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
        guard let file = self.fileToDrag, type == .fileURL else {
            return
        }
        
        item.setString(file.fileContent.path, forType: .fileURL)
        logger.info("Provided file URL data for drag operation.")
    }
}


// Helper extension to create a snapshot for the drag image
extension View {
    func snapshot() -> NSImage? {
        let controller = NSHostingController(rootView: self.ignoresSafeArea())
        let targetSize = controller.view.intrinsicContentSize
        guard targetSize.width > 0, targetSize.height > 0 else { return nil }
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.layout()

        let bitmap = controller.view.bitmapImageRepForCachingDisplay(in: controller.view.bounds)
        if let bitmap = bitmap {
            controller.view.cacheDisplay(in: controller.view.bounds, to: bitmap)
            let image = NSImage(size: bitmap.size)
            image.addRepresentation(bitmap)
            return image
        }
        return nil
    }
}

class FileDragSource: NSObject, NSDraggingSource {
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }

    // This method is optional but good practice. It's called when the drag is finished.
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        print("Drag session ended.")
    }
}
