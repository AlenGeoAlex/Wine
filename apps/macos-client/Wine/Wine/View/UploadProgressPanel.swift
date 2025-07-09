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

class UploadProgressPanel: NSPanel {

    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "UploadProgress")
    private let windowWidth = 100
    private let windowHeight = 100
    
    let id : UUID = UUID()
    private let captureFile : CapturedFile
    private let fileUploader : FileUploader
    let view = CloudUploadProgress();

    init(captureFile: CapturedFile, fileUploader: FileUploader){
        self.captureFile = captureFile
        self.fileUploader = fileUploader
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
            rootView: view
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
    
    public func updateProgress(progress: Double){
        view.model.updateProgress(progress: progress)
    }
    
    private func closePanel(){
        logger.info("Completed ClosePanel from CloudUploadPanel")
    }
}
