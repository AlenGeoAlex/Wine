//
//  PreviewPanel.swift
//  Wine
//
//  Created by Alen Alex on 26/06/25.
//

import Foundation
import AppKit
import SwiftUI
import OSLog
import FactoryKit

class PreviewPanel : NSPanel {
    
    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "PreviewPanel")
    private let windowWidth = 320.0
    private let windowHeight = 120.0
    private let windowPadding = 15.0
    
    let id : UUID = UUID()
    
    private let captureFile : CapturedFile
    private let onClose : (UUID) -> Void;
    private let padding: CGFloat;
    private var autoDismissTimer: Timer?
    private var isClosed: Bool = false
    private var timerFinished: Bool = false
    private var isInteracting: Bool = false

    
    init(padding: CGFloat, captureFile: CapturedFile, onClose: @escaping (UUID) -> Void){
        self.onClose = onClose
        self.padding = padding
        self.captureFile = captureFile
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel, .titled],
            backing: .buffered,
            defer: true
        )
        self.autoDismissTimer = self.setTimer()
        self.setupWindow()
        setupContent();
    }
    
    private func setTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.timerFinished = true
            if(isInteracting){
                self.logger.info( "Timer finished, but preview is still interacting")
                return
            }
            
            closePanel();
        }
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
        let hostingView = DraggableHostingView(rootView: PreviewViewComponent(uploadContent: captureFile, onClose: {
            self.closePanel();
            self.logger.info( "Close PreviewPanel from PreviewPanel")
        }, isInInteraction: {
            interacting in
            self.toggleInteracting(interacting: interacting)
        }), fileToDrag: captureFile )
        self.contentView = hostingView
        hostingView.setFrameSize(hostingView.fittingSize);
        
        if let screen = NSScreen.active {
            
            let screenFrame = screen.visibleFrame
            let xPosition = screenFrame.maxX - hostingView.frame.width - 20
            let yPosition = screenFrame.minY + 40
            
            self.setFrameOrigin(NSPoint(x: xPosition, y: yPosition))
            self.setContentSize(hostingView.frame.size)
        }
    }
    
    var window : NSWindow? {
        guard let window = self.contentView?.window else {
            return nil;
        }
        
        return window
    }
    
    private func toggleInteracting(interacting: Bool){
        if(interacting){
            isInteracting = true
        }else{
            isInteracting = false
            if timerFinished {
                closePanel();
            }
        }
    }
    
    private func closePanel(){
        guard let timer = self.autoDismissTimer else {
            return;
        }
        
        if timer.isValid {
            timer.invalidate()
            logger.info( "Auto dismiss timer invalidated for .\(self.id)")
        }
        
        onClose(self.id)
        logger.info("Completed ClosePanel from PreivewPanel")
    }
    
}
