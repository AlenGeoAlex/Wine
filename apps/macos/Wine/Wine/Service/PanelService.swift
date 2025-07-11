//
//  PanelService.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import Foundation
import AppKit
import FactoryKit
import OSLog
import Combine

class PanelService {
    
    private var panels : [UUID : NSPanel] = [:];
    private let logger : Logger = Logger.create();
    
    init (container: Container) {
        
    }
    
    func openPreviewPanel(for capture: Capture){
        let previewPanel = PreviewPanel(capture: capture)
        panels[previewPanel.id] = previewPanel
        previewPanel.makeKeyAndOrderFront(nil);
        previewPanel.makeKey();
        logger.trace("Opening preivew panel for capture \(capture.id.uuidString)")
    }
    
    func closePreviewPanel(with id: UUID){
        guard let panel = panels[id] else {
            logger.warning( "Could not find preview panel for id \(id.uuidString)")
            return;
        }
        
        if !(panel is PreviewPanel) {
            logger.warning( "Preview panel for id \(id.uuidString) is not of type PreviewPanel")
            return;
        }
        
        guard let previewPanel = panel as? PreviewPanel else {
            logger.warning( "Could not cast preview panel for id \(id.uuidString) to PreviewPanel")
            return;
        }
        
        guard let window = previewPanel.window else {
            previewPanel.close()
            logger.warning( "Preview panel for id \(id.uuidString) does not have a window")
            return;
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            window.animator().alphaValue = 0
        }, completionHandler: {
            panel.close()
            self.panels.removeValue(forKey: id)
            self.logger.info( "Closed preivew panel for capture \(id.uuidString)")
        })
        self.panels.removeValue(forKey: id)
    }
}
