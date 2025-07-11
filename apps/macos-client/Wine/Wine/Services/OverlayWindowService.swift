//
//  OverlayWindowService.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Foundation
import Cocoa
import OSLog
import FactoryKit

class OverlayWindowService : NSObject {
    
    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "OverlayWindowService");
    
    private var overlayWindows : [UUID : PreviewPanel] = [:];
    private var cloudShareWindow : [UUID : NSWindow] = [:];
    private var progressOverlay : [UUID : NSWindow] = [:];
    
    public func showCloudShare(with captureFile: CapturedFile){
        let cloudSharePanel = CloudUploadPanel(
            captureFile: captureFile,
            onClose: { id in
                self.closeCloudShare(for: id)
                self.showPreview(with: captureFile)
            },
            onUpload: {
                (id, captureFile, uploadData) in
                print(id)
                Task {
                    print(uploadData.fileName)
                    await Container.shared.screenshotOrchestra.resolve().upload(capturedFile: captureFile, cloudShareOverlay: uploadData)
                }
            }
        )
        
        cloudShareWindow[cloudSharePanel.id] = cloudSharePanel
        cloudSharePanel.makeKeyAndOrderFront(nil)
        cloudSharePanel.makeKey()
        logger.info("Showing cloud share window")
    }
    
    public func showProgressOverlay(for captureFile: CapturedFile, id: String) async -> URL? {
        let uploadProgressPanel :UploadProgressPanel = await UploadProgressPanel(captureFile: captureFile)
        progressOverlay[uploadProgressPanel.id] = uploadProgressPanel
        let fileUploader = FileUploader();
        await uploadProgressPanel.makeKeyAndOrderFront(nil)
        await uploadProgressPanel.makeKey()
        logger.info("Showing cloud progress window")

        let url = await fileUploader.uploadFile(id: id, for: captureFile, progressHandler: {
            progress in
            Task {
                @MainActor in
                uploadProgressPanel.updateProgress(progress: progress)
            }
        })
        closeProgressOverlay(for: uploadProgressPanel.id)
        return url
    }
    
    
    public func closeProgressOverlay(for uuid: UUID){
        guard let panel = progressOverlay[uuid] else {
            logger.error("Could not find progress overlay window for \(uuid)")
            return
        }
        
        panel.close()
        progressOverlay[uuid] = nil
    }
    
    public func closeCloudShare(for uuid: UUID){
        guard let panel = cloudShareWindow[uuid] else {
            logger.error("Could not find cloud share window for \(uuid)")
            return
        }
        
        panel.close()
        cloudShareWindow[uuid] = nil
    }
    
    public func showPreview(with captureFile: CapturedFile){
        let previewPanel = PreviewPanel(
            padding: 20, captureFile: captureFile, onClose: {
                id in
                self.closePreview(for: id)
            }
        )
        
        overlayWindows[previewPanel.id] = previewPanel
        previewPanel.makeKeyAndOrderFront(nil)
        previewPanel.makeKey()
        logger.info("Showing overlay window")
    }
    
    public func closePreview(for uuid: UUID){
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
