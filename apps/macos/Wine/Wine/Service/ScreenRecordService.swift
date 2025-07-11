//
//  ScreenRecordService.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
import FactoryKit
import OSLog
import Combine

class ScreenRecordService {
    
    private let logger : Logger = Logger.create();
    private let _currentScreenRecord : CurrentValueSubject<Capture?, Never> = .init(nil);
    
    public let screenRecordings : AnyPublisher<Capture?, Never>;
    
    init(container: Container){
        self.screenRecordings = _currentScreenRecord.eraseToAnyPublisher();
    }
    
    // MARK: Computer Properties
    
    // Is currently recording
    public var isRecording : Bool {
        return _currentScreenRecord.value != nil;
    }
    
    // Is currently free of recordig
    public var isNotRecording : Bool {
        return !isRecording;
    }
    
    // Get the active recording
    public var currentRecording: Capture? {
        return _currentScreenRecord.value;
    }
    
}
