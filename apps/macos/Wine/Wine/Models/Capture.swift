//
//  Capture.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//
import FactoryKit
import OSLog
import Swift
import Combine
import UniformTypeIdentifiers
import AppKit
import AVFoundation

class Capture : NSObject, Identifiable {
    
    static func preview() -> Capture {
        return Capture(type: .screenshot(ScreenshotOptions.defaultSettings()), ext: ".png", filePath: URL(string: "https://imgur.com/gallery/inferno-tree-lRYUhYh#/t/abstract_art")!)
    }
    
    static let log : Logger = Logger.create();
    deinit {
        Self.log.debug("Capture deinitialized")
    }
    
    // MARK: Immutable Properties
    let type: CaptureType;
    let filePath: URL;
    let fileExtension: String;
    let contentType: String;
    let imagePreview: AnyPublisher<NSImage?, Never>;
    
    var name: String;
    private(set) var id = UUID();
    private var _isContentAvailable: Bool = false;
    private var _previewImage: CurrentValueSubject<NSImage?, Never>;
    
    init(
        id: UUID = UUID(),
        type: CaptureType,
        ext fileExtension: String,
        filePath: URL? = nil // Only for previews
    ) {
        self.id = id
        self.type = type
        self.name = "\(type.filePrefix)-\(id.normalized())"
        self.fileExtension = fileExtension
        self.contentType = Self.getContentType(ext: fileExtension)
        self.filePath = filePath ?? FileManager.default.temporaryDirectory
            .appending(path: WineConstants.appName)
            .appending(path: Formatters.justYMDDate.string(from: Date()))
            .appending(path: name)
            .appendingPathExtension(fileExtension)
        self._previewImage = CurrentValueSubject(nil);
        self.imagePreview = self._previewImage.eraseToAnyPublisher();
        super.init();
        self.initParentDirectory();
        Self.log.debug("Capture initialized: \(self.filePath)")
    }
    
    func currentPreviewImage() -> NSImage? {
        return self._previewImage.value;
    }
    
    private func initParentDirectory() {
        do {
            try FileManager.default.createDirectory(
                at: self.filePath.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
        }catch {
            Self.log.error("Failed to create parent directory for capture file: \(error)")
        }
    }
    
    public func setContentAvailable(){
        if self._isContentAvailable { return }
        
        self._isContentAvailable = true
        NotificationCenter.default.post(
            name: .captureContentAvailable,
            object: self,
            userInfo: [
                "id": self.id
            ]
        )
        Task {
            await generateThumabnail()
        }
    }
    
    public func delete(){
        do {
            try FileManager.default.removeItem(at: self.filePath)
        }catch {
            Self.log.error("Failed to delete capture file: \(error)")
        }
    }
    
    public func copyCaptureToClipboard(){
        let pasteboard = NSPasteboard.general;
        pasteboard.clearContents();
        pasteboard.writeObjects(
            [filePath as NSURL]
        )
    }
    
    private func generateThumabnail() async {
        var img: NSImage?;
        switch self.type {
        case .screenshot:
            img = NSImage(contentsOf: self.filePath)
            break;
        case .screenrecord:
            let avAsset = AVURLAsset(url: self.filePath);
            let imageGenerator = AVAssetImageGenerator(asset: avAsset);
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.maximumSize = CGSize(width: 1024, height: 1024)
            
            do {
                let timePoint = CMTimeMakeWithSeconds(1, preferredTimescale: 60)
                let (genImg, _) = try await imageGenerator.image(at: timePoint)
                img = NSImage(cgImage: genImg, size: CGSize(width: 1024, height: 1024))
            } catch {
                Self.log.error("Failed to generate thumbnail for \(self.id) - \(self.filePath) due to \(error)")
            }
            break;
        }
        
        guard let img else {
            Self.log.warning("Failed to get a valid image for \(self.id) - \(self.filePath)")
            return
        }
        self._previewImage.send(img);
    }
    
    private static func getContentType(ext fileExtension: String) -> String {
        switch fileExtension {
        case "mp4":
            return "video/mp4"
        case "jpeg", "jpg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "mov":
            return "video/quicktime"
        case "gif":
            return "image/gif"
        default:
            return "application/octet-stream"
        }
    }
    
    private static func utType(ext fileExtension: String) -> UTType?{
        switch fileExtension {
        case "mp4", "mov":
            return .movie
        case "jpeg", "jpg", "png":
            return .image;
        case "gif":
            return .gif
        default:
            return nil
        }
    }
}

