//
//  AVDeviceHelper.swift
//  Wine
//
//  Created by Alen Alex on 23/06/25.
//

import Foundation
import AVFoundation
import AppKit

class AVDeviceHelper {
        
    static func getAudioDevices() -> [AVCaptureDevice] {
        if #available(macOS 14.0, *) {
            return AVCaptureDevice.DiscoverySession(
                deviceTypes: [.microphone], mediaType: .audio, position: .unspecified).devices
        }else{
            return [];
        }
    }
    
}
