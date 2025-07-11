//
//  WineListener.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
import AppKit
import Combine
import OSLog
import FactoryKit

class WineListener  {
    
    private var logger : Logger = Logger.create();
    private var cancellables: Set<AnyCancellable> = []
    @Injected(\.panelService) private var panelService: PanelService;
    
    init(){
        NotificationCenter.default
            .publisher(for: .captureContentAvailable)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.object as? Capture }
            .sink { [weak self] capture in
                self?.logger.info("Recieved a new capture with content available. CaptureID: \(capture.id)")
                self?.onCaptureContentBecomeAvailable(capture)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .previewPanelClosed)
            .receive(on: DispatchQueue.main)
            .compactMap {
                let capture = $0.object as? Capture
                let id = $0.userInfo?["id"] as? UUID
                return (capture, id)
            }
            .sink { [weak self] (capture: Capture?, id: UUID?) in
                guard let cap = capture, let validId = id else {
                    self?.logger.warning("Failed to parse capture and id from notification")
                    return;
                }
                self?.logger.info( "Recieved Preview panel closed for capture \(String(describing: capture?.id)) with id \(String(describing: id))")
                self?.onPreviewPanelClosed(with: validId, for: cap)
            }
            .store(in: &cancellables)
    }
    
    private func onCaptureContentBecomeAvailable(_ capture: Capture){
        panelService.openPreviewPanel(for: capture)
    }
    
    private func onPreviewPanelClosed(with id: UUID, for capture: Capture){
        panelService.closePreviewPanel(with: id)
    }
    
}
