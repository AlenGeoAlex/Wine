//
//  ImageHelper.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import Foundation
import CoreImage
import ScreenCaptureKit
import AVFoundation
import AppKit


class ImageHelper {
    public static func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> NSImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: ciImage.extent.size)
    }

}
