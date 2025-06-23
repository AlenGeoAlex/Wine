//
//  ImageCaptureProtocol.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import AppKit;
import Combine;
/**
 Protocol which defines image capturing
 */
protocol ImageCaptureProtocol {
    
    /// Capture image with Selection
    func captureImageWithSelection() async throws -> Result<URL, CaptureError>
    
    /// Capture an entire screen
    func captureScreen(id: Int) async throws ->  Result<URL, CaptureError>
    
}
