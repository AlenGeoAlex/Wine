//
//  ScreenCaptureSession.swift
//  Wine
//
//  Created by Alen Alex on 23/06/25.
//

import Foundation
import ScreenCaptureKit
import OSLog
import AppKit
import Combine

@available(macOS 15.0, *)
class ScreenCaptureSession : NSObject, SCStreamDelegate, SCRecordingOutputDelegate, SCStreamOutput {
    
    
    let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "ScreenCaptureSession")
    let outputURL : URL!
    var contentFilter: SCContentFilter!
    var streamConfiguration: StreamConfiguration!;
    
    var scStreamConfiguration: SCStreamConfiguration?;
    var scRecordingConfiguration: SCRecordingOutputConfiguration!

    var scStream : SCStream?;
    var scRecordingOutput : SCRecordingOutput?;
    
    var started : Bool = false;
    
    let onFileReady : (SCRecordingOutput) -> Void
    
    init(contentFiler: SCContentFilter, streamConfiguration: StreamConfiguration, onFileReady: @escaping (SCRecordingOutput) -> Void){
        self.contentFilter = contentFiler
        self.streamConfiguration = streamConfiguration
        self.outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
        logger.info("Output URL is \(self.outputURL)")
        self.onFileReady = onFileReady
    }
    
    func start(){
        self.scStreamConfiguration = prepareSCStreamConfiguration();
        let x = prepareRecordingOutputConifguration();
        self.scRecordingConfiguration = x.0;
        self.scRecordingOutput = x.1;
        
        do {
            self.scStream = SCStream(filter: self.contentFilter, configuration: self.scStreamConfiguration!, delegate: self)
            try scStream!.addStreamOutput(self, type: .screen, sampleHandlerQueue: nil)
            try scStream!.addStreamOutput(self, type: .microphone, sampleHandlerQueue: nil)
            try self.scStream!.addRecordingOutput(self.scRecordingOutput!)
            logger.info("Stream has been started to capture at \(self.self.scRecordingConfiguration.outputURL)  with desc \(self.scRecordingOutput?.description ?? "nil")")
            self.scStream!.startCapture()
            self.started = true;
        }
        catch
        {
            logger.error("Failed to start screen capture session: \(error)")
        }
    }
    
    func stop(){
        do {
            if(!started)
            {
                logger.warning("Try to stop the screen capture session that is not started")
                return;
            }
            
            if(self.scStream == nil)
            {
                logger.error("Failed to stop the screen capture sesion: SCStream is nil")
                return;
            }
            
            if(self.scRecordingOutput != nil){
                try self.scStream!.removeRecordingOutput(self.scRecordingOutput!);
            }
            self.scStream!.stopCapture();
        }catch {
            logger.error("Failed to stop the screen capture sesion: \(error)")
        }
    }
    
    private func prepareSCStreamConfiguration() -> SCStreamConfiguration {
        let config : SCStreamConfiguration = self.scStreamConfiguration ?? SCStreamConfiguration();
        
        if(streamConfiguration.captureMicrophone){
            config.captureMicrophone = true
            config.microphoneCaptureDeviceID = AVCaptureDevice.default(for: .audio)?.uniqueID ?? ""
            logger.info("Microphone has been set to capture")
        }
        
        if(streamConfiguration.captureSystemAudio){
            config.capturesAudio = true;
            logger.info("System audio is set to be captured")
        }
        
        if(streamConfiguration.showCursor){
            config.showsCursor = true;
        }else{
            config.showsCursor = false;
        }
        
        config.minimumFrameInterval = streamConfiguration.frameRateInterval;
        config.sampleRate = streamConfiguration.sampleRate;
        config.channelCount = streamConfiguration.channelCount;
        return config;
    }
    
    private func prepareRecordingOutputConifguration() -> (SCRecordingOutputConfiguration, SCRecordingOutput) {
        let recordingConfiguration = SCRecordingOutputConfiguration()
                
        recordingConfiguration.outputURL = outputURL
        recordingConfiguration.outputFileType = .mp4;
        recordingConfiguration.videoCodecType = .h264
        
        let recordingOutput = SCRecordingOutput(configuration: recordingConfiguration, delegate: self)
        return (recordingConfiguration, recordingOutput);
    }
    
    func updateFilter(filter: SCContentFilter){
        self.contentFilter = filter
        if(scStream != nil){
            scStream!.updateContentFilter(filter);
            logger.info("Content filter has been updated by the user")
        }
    }
    
    func updateStreamConfiguration(config: StreamConfiguration){
        self.streamConfiguration = config
        self.scStreamConfiguration = prepareSCStreamConfiguration();
        if(scStream != nil){
            scStream!.updateConfiguration(self.scStreamConfiguration!)
            logger.info("Content configuration has been updated by the user")
        }
    }
    
    func recordingOutputDidFinishRecording(_ recordingOutput: SCRecordingOutput) {
        logger.info("Recording finished")
        logger.info("\(recordingOutput.description)")
    }
    
    deinit {
        if(scStream != nil){
            if(scRecordingOutput != nil){
                do {
                    try scStream!.removeRecordingOutput(scRecordingOutput!)
                }catch {
                    logger.error("Failed ot remove recording output on deinit")
                }
            }
            
            scStream?.stopCapture();
        }
    
    }
    
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        switch type {
        case .screen:
            break;
        case .audio:
            break;
        case .microphone:
            break;
        default :
            break;
        }
    }
    
}
