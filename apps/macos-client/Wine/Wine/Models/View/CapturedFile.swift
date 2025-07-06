//
//  CapturedFile.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Foundation
import AppKit
import AVFoundation

actor CapturedFile {
    let fileContent: URL
    let type: OutputFileType
    let captureType: CaptureType
    
    private var cachedImageWrapper: SendableImage?
    init(fileContent: URL, type: OutputFileType, captureType: CaptureType) {
        self.fileContent = fileContent
        self.type = type
        self.captureType = captureType

    }
    
    private func popuplateImageCache() {
        if captureType == .screenshot {
            guard let image = NSImage(contentsOf: fileContent) else { return }
            self.cachedImageWrapper = SendableImage(image: image)
        }
    }
    
    var fileName: String {
        return fileContent.lastPathComponent
    }
    
    var mimeType: String {
        return FileHelpers.mimeTypeForPathExtension(fileContent.pathExtension)
    }
    
    func getThumbnailImage(at time: TimeInterval = 1.0) async -> SendableImage? {
        if let cachedImageWrapper {
            return cachedImageWrapper
        }
        
        let newImage: NSImage?
        
        if self.captureType == .video {
            newImage = await generateVideoThumbnail(at: time)
        } else {
            newImage = await loadImageFromURL()
        }
        
        if let newImage {
            let wrapper = SendableImage(image: newImage)
            self.cachedImageWrapper = wrapper
            return wrapper
        }
        
        return nil
    }
    
    /// Private helper to generate a video thumbnail as an NSImage.
    private func generateVideoThumbnail(at time: TimeInterval) async -> NSImage? {
        let asset = AVURLAsset(url: fileContent)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 1024, height: 1024)
        
        do {
            let timePoint = CMTime(seconds: time, preferredTimescale: 600)
            let (cgImage, _) = try await imageGenerator.image(at: timePoint)
            return NSImage(cgImage: cgImage, size: .zero)
        } catch {
            return nil
        }
    }
    
    /// Private helper to load an image from a URL as an NSImage.
    private func loadImageFromURL() async -> NSImage? {
        // NSImage(contentsOf:) correctly loads images with their scale factors.
        return NSImage(contentsOf: fileContent)
    }
}
