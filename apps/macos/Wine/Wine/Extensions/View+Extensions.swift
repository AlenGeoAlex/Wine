//
//  View+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI
import AppKit

extension View {
    /// Renders the SwiftUI view into an NSImage.
    /// - Parameter size: The desired size of the output image. If nil, the view's ideal size is used.
    /// - Returns: An NSImage representation of the view, or nil if rendering fails.
    func renderAsImage(size: CGSize) -> NSImage? {
        let hostingView = NSHostingView(rootView: self.ignoresSafeArea())
        
        hostingView.frame = CGRect(origin: .zero, size: size)
        
        guard let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else {
            return nil
        }
        
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmapRep)
        
        let image = NSImage(size: bitmapRep.size)
        image.addRepresentation(bitmapRep)
        
        return image
    }
    
    @ViewBuilder
    func draggable(if condition: Bool, annotation: Binding<TextAnnotation>) -> some View {
        if condition {
            self.gesture(
                DragGesture()
                    .onChanged { value in
                        let startPosition = annotation.wrappedValue.position
                        annotation.wrappedValue.position = CGPoint(
                            x: startPosition.x + value.translation.width,
                            y: startPosition.y + value.translation.height
                        )
                    }
            )
        } else {
            self
        }
    }
}
