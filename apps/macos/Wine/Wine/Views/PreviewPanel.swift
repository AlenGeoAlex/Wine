//
//  PreviewPanel.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import Cocoa
import FactoryKit
import OSLog
import AppKit
import Combine
import Foundation
import SwiftUI
import Defaults

class PreviewPanel: NSPanel, Identifiable {

    private let logger : Logger = Logger.create();
    let id : UUID = UUID();
    
    private let capture: Capture;
    
    init(capture: Capture) {
        self.capture = capture
        super.init(
            contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel, .titled], backing: .buffered, defer: true
        );
        self.initWindow();
        self.setupContent();
    }
    
    private func initWindow(){
        self.backgroundColor = .clear;
        self.isOpaque = false;
        self.hasShadow = false;
        self.level = .floating;
        self.isMovableByWindowBackground = true;
        self.titlebarAppearsTransparent = true;
        self.titleVisibility = .hidden;
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
    }
    
    private func setupContent(){
        let previewOverlay = PreviewOverlay(with: self.id, for: self.capture);
        let hostingView = NSHostingView(
            rootView: previewOverlay
        );
        self.contentView = hostingView;
        hostingView.setFrameSize(hostingView.fittingSize);
        if let position = Defaults[.previewPanelPosition].getRelativePosition(contentRect: hostingView.frame) {
            self.setFrameOrigin(NSPoint(x: position.x, y: position.y))
        }
        self.setContentSize(hostingView.frame.size)
    }
    
    var window : NSWindow? {
        guard let window = self.contentView?.window else {
            return nil;
        }
        
        return window
    }
}
