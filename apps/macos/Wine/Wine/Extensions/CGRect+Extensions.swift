//
//  CGRect+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//
import CoreGraphics

extension CGRect {
    func update(for handle: CropViewHandle, with translation: CGSize) -> CGRect {
        var newRect = self
        
        switch handle {
        case .topLeft:
            newRect.origin.x += translation.width
            newRect.origin.y += translation.height
            newRect.size.width -= translation.width
            newRect.size.height -= translation.height
        case .top:
            newRect.origin.y += translation.height
            newRect.size.height -= translation.height
        case .topRight:
            newRect.origin.y += translation.height
            newRect.size.width += translation.width
            newRect.size.height -= translation.height
        case .left:
            newRect.origin.x += translation.width
            newRect.size.width -= translation.width
        case .right:
            newRect.size.width += translation.width
        case .bottomLeft:
            newRect.origin.x += translation.width
            newRect.size.height += translation.height
            newRect.size.width -= translation.width
        case .bottom:
            newRect.size.height += translation.height
        case .bottomRight:
            newRect.size.width += translation.width
            newRect.size.height += translation.height
        case .move:
            newRect.origin.x += translation.width
            newRect.origin.y += translation.height
        }
        
        return newRect
    }

}
