//
//  StreamConfiguration.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI
import ScreenCaptureKit

struct StreamConfiguration {
    
    var captureMicrophone: Bool = true;
    
    var captureSystemAudio: Bool = true;
    
    var showCursor : Bool = true;
    
    var sampleRate : Int = 44100;
    
    var channelCount : Int = 2;
    
    var frameRateInterval : CMTime =  CMTime(value: 1, timescale: 24);
    
    var outputType : StreamOutputType = .mp4;
    
    var selectedAudioDevice : AudioDevice? = .first();
}

enum StreamOutputType : String, Hashable, CaseIterable, Identifiable {
    
    var id : String {
        self.rawValue
    }
    
    case mp4 = "mp4";
    case mov = "mov"
}
