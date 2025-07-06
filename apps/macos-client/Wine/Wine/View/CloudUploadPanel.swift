//
//  CloudUploadPanel.swift
//  Wine
//
//  Created by Alen Alex on 06/07/25.
//

import Cocoa
import OSLog
import AppKit
import FactoryKit
import SwiftUI

class CloudUploadPanel: NSPanel {

    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "PreviewPanel")
    private let windowWidth = 500
    private let windowHeight = 300
    
    let id : UUID = UUID()
    private let captureFile : CapturedFile
    private let onClose : (UUID) -> Void;
    private let onUpload : (UUID, CapturedFile, CloudShareOverlayModel) -> Void;
    
    init(captureFile: CapturedFile, onClose: @escaping (UUID) -> Void,  onUpload : @escaping (UUID, CapturedFile, CloudShareOverlayModel) -> Void){
        self.onClose = onClose
        self.captureFile = captureFile
        self.onUpload = onUpload
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel, .titled],
            backing: .buffered,
            defer: true
        )
        self.setupWindow()
        setupContent();
    }
    
    private func setupWindow(){
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.level = .floating
        self.isMovableByWindowBackground = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        
        self.collectionBehavior = [
            .canJoinAllSpaces,
            .stationary
        ]
    }
    
    private func setupContent(){
        let hostingView = NSHostingView(
            rootView: CloudShareOverlay(
                capturedFile: captureFile, onCancel: {
                    self.closePanel();
                    self.logger.info( "Close PreviewPanel from PreviewPanel")
                }, onShare: { (model, captureFile) in
                    self.onUpload(self.id, captureFile, model);
                }
            )
        )
        self.contentView = hostingView
        hostingView.setFrameSize(hostingView.fittingSize);
        
        if let screen = NSScreen.active {
            let screenFrame = screen.visibleFrame
            let panelSize = hostingView.fittingSize

            let xPosition = screenFrame.midX - (panelSize.width / 2)
            let yPosition = screenFrame.midY - (panelSize.height / 2)

            self.setContentSize(panelSize)
            self.setFrameOrigin(NSPoint(x: xPosition, y: yPosition))
        }
    }
    
    private func closePanel(){
        onClose(self.id)
        logger.info("Completed ClosePanel from CloudUploadPanel")
    }
}
