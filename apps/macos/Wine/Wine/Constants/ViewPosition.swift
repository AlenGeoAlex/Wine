//
//  ViewPosition.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import Defaults
import CoreFoundation
import AppKit

enum ViewPosition : String, Defaults.Serializable {
    case topLeft = "topLeft"
    case topRight = "topRight"
    case bottomLeft = "bottomLeft"
    case bottomRight = "bottomRight"
    case bottomCenter = "bottomCenter"
    
    public func getRelativePosition(contentRect: NSRect, xOffset: CGFloat = 20, yOffset: CGFloat = 40) -> (x: CGFloat,y: CGFloat)? {
        switch self {
        case .bottomRight:
            if let screen = NSScreen.active {
                let screenFrame = screen.visibleFrame;
                let xPosition = screenFrame.maxX - contentRect.width - xOffset
                let yPosition = screenFrame.minY + yOffset
                
                return (xPosition, yPosition)
            }
            return nil;
        case .topRight:
            if let screen = NSScreen.active {
                let screenFrame = screen.visibleFrame;
                let xPosition = screenFrame.maxX - contentRect.width - xOffset
                let yPosition = screenFrame.maxY - yOffset;
                
                return (xPosition, yPosition)
            }
            return nil;
        case .bottomLeft:
            if let screen = NSScreen.active {
                let screenFrame = screen.visibleFrame;
                let xPosition = screenFrame.minX + xOffset
                let yPosition = screenFrame.minY + yOffset
                
                return (xPosition, yPosition)
            }
            return nil;
        case .topLeft:
            if let screen = NSScreen.active {
                let screenFrame = screen.visibleFrame;
                let xPosition = screenFrame.minX + xOffset
                let yPosition = screenFrame.maxY + yOffset
                
                return (xPosition, yPosition)
            }
            return nil;
        case .bottomCenter:
            if let screen = NSScreen.active {
                let screenFrame = screen.visibleFrame;
                let xPosition = (screenFrame.maxX - contentRect.width) / 2
                let yPosition = screenFrame.minY + yOffset
                
                return (xPosition, yPosition)
            }
            return nil;
        }
    }
}
