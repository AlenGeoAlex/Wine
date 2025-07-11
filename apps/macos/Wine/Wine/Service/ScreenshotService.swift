//
//  ScreenshotService.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
import FactoryKit
import OSLog
import Combine

class ScreenshotService {
    
    private let logger : Logger = Logger.create();
    private let _screenshotSubject : CurrentValueSubject<Capture?, Never> = .init(nil);
    public let screenshots : AnyPublisher<Capture?, Never>;
    
    init(container: Container){
        self.screenshots = _screenshotSubject.eraseToAnyPublisher();
    }
    
    public func capture() async -> Result<Capture, ScreenshotError> {
        let options = ScreenshotOptions.defaultSettings();
        let capture : Capture = Capture(
            type: CaptureType.screenshot(options),
            ext: options.format.id
        )
        
        do {
            let process = Process();
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            process.arguments = ["-x", "-i", "-s", capture.filePath.path]
            
            try process.run();
            process.waitUntilExit();
            
            guard process.terminationStatus == 0 else {
                logger.warning("User cancelled screenshot capture")
                return .failure(.cancelled)
            }
            
            guard FileManager.default.fileExists(atPath: capture.filePath.path) else {
                logger.warning("Screenshot file not found at path : \(capture.filePath.path)");
                return .failure(.unknown);
            }
            
            capture.setContentAvailable();
            return .success(capture);
        }catch {
            logger.error("Failed to capture screenshot : \(error)");
            return .failure(.unknown);
        }
    }
    
}
