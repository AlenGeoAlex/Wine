//
//  SCVideoCapture.swift
//  Wine
//
//  Created by Alen Alex on 23/06/25.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine
import OSLog
import ScreenCaptureKit

@available(macOS 15.0, *)
class SCVideoCapture : NSObject, ObservableObject, SCContentSharingPickerObserver {
    
    var versionId : UUID = UUID();
    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "SCVideCapture")
    private var contentPicker : SCContentSharingPicker?;
    
    
    @Published var isRecording : Bool = false
    var session: ScreenCaptureSession? = nil
    var streamConfiguration : StreamConfiguration? = nil
    
    private let notificationService : NotificationService;
    
    init(notificationService : NotificationService){
        self.notificationService = notificationService;
    }
    
    func requestRecordingSource(conf: StreamConfiguration){
        if(contentPicker == nil){
            setupContentPicker();
        }
        
        streamConfiguration = conf;
        contentPicker!.present(using: .none);
    }
    
    func requestRecordingSelection(conf: StreamConfiguration){
        
    }
    
    private func startRecording(filter: SCContentFilter){
        if(session != nil){
            session?.updateFilter(filter: filter);
        }else{
            session = ScreenCaptureSession(contentFiler: filter, streamConfiguration: self.streamConfiguration ?? StreamConfiguration(), onFileReady: {
                event in
                print("File has been ready at \(event.description)")
            });
            session?.start();
            logger.info("Recording has been told to start")
        }
        self.versionId = UUID();
    }
    
    func stopRecording(){
        streamConfiguration = nil;
        if(session == nil)
        {
            return
        }
        
        session?.stop();
        self.versionId = UUID();
    }
    
    private func setupContentPicker(){
        if(contentPicker != nil){
            return;
        }
        
        contentPicker = SCContentSharingPicker.shared;
        var config = SCContentSharingPickerConfiguration();
        config.allowedPickerModes = .singleDisplay
        config.excludedBundleIDs = [Bundle.main.bundleIdentifier!];
        contentPicker?.maximumStreamCount = 2
        contentPicker?.configuration = config;
        contentPicker?.isActive = true;
        contentPicker?.add(self)
    }
    
    func contentSharingPicker(_ picker: SCContentSharingPicker, didCancelFor stream: SCStream?)
    {
        logger.info("User has cancelled the sesion")
    }
    

    func contentSharingPicker(_ picker: SCContentSharingPicker, didUpdateWith filter: SCContentFilter, for stream: SCStream?){
        startRecording(filter: filter)
        logger.info("Recording source has been selected!");
    }
    

    func contentSharingPickerStartDidFailWithError(_ error: any Error){
        logger.error("Failed to start the request as an error happened!");
    }
}
