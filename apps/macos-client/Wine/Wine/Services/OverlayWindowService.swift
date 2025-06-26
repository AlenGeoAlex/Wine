//
//  OverlayWindowService.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Foundation
import Cocoa
import OSLog

class OverlayWindowService : NSObject {
    
    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "OverlayWindowService");
    
    private var overlayWindows : [UUID : PreviewPanel] = [:];
    
    public func showOverlay(with captureFile: CapturedFile){
        let previewPanel = PreviewPanel(
            padding: 20, captureFile: captureFile, onClose: {
                id in
                self.closeOverlay(for: id)
            }
        )
        
        overlayWindows[previewPanel.id] = previewPanel
        previewPanel.makeKeyAndOrderFront(nil)
        previewPanel.makeKey()
        logger.info("Showing overlay window")
    }
    
    public func closeOverlay(for uuid: UUID){
        guard let panel = overlayWindows[uuid] else {
            logger.error("Could not find overlay window for \(uuid)")
            return
        }
        
        guard let window = panel.window else {
            logger.error("Could not find window for overlay with id \(uuid)")
            panel.close()
            self.logger.warning("Failed to find the window, no animation performed.")
            return
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            window.animator().alphaValue = 0
        }, completionHandler: {
            panel.close()
            self.overlayWindows.removeValue(forKey: uuid)
            self.logger.info("Closed and removed overlay with id \(uuid). Remaining: \(self.overlayWindows.count)")
        })
        overlayWindows.removeValue(forKey: uuid)
    }

}
