//
//  GlobalCGTap.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import Foundation
import AppKit
import Combine
import CoreGraphics
import FactoryKit
import OSLog

private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else {
        return Unmanaged.passUnretained(event)
    }
    
    let monitor = Unmanaged<GlobalCGTap>.fromOpaque(refcon).takeUnretainedValue()
    
    //
    let shouldHandle = MainActor.assumeIsolated { () -> Bool in
        return monitor.shouldHandle(event: event, type: type)
    }
    
    if shouldHandle {
        return nil
    }
    
    return Unmanaged.passUnretained(event)
}

class GlobalCGTap {

    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "GlobalCGTap")
    private let settingsService : SettingsService;
    private let appOrchestra : AppOrchestra;
    private var cancellables : Set<AnyCancellable>;
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    @MainActor
    init(container: Container){
        self.appOrchestra = container.screenshotOrchestra.resolve();
        self.settingsService = container.settingsService.resolve();
        self.cancellables = [];
        
        self.settingsService.appSettings
            .bindings
            .publisher
            .sink { [weak self] _ in
                self?.registerKeybinds()
                self?.logger.info("Found change in keybinds, restarting monitor complete")
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func shouldHandle(event: CGEvent, type: CGEventType) -> Bool {
        guard type == .keyDown else { return false }
        guard let nsEvent = NSEvent(cgEvent: event) else { return false }

        let relevantFlags: NSEvent.ModifierFlags = [.command, .option, .control, .shift]
        let eventModifiers = nsEvent.modifierFlags.intersection(relevantFlags)

        let key = nsEvent.charactersIgnoringModifiers?.lowercased()
        
        for (action, keyCombo) in settingsService.appSettings.bindings
        {
            guard let keyInBinding = keyCombo.key else { continue }
            
            if(key == keyInBinding.lowercased() && eventModifiers == keyCombo.modifiers){
                handle(action: action)
                return true;
            }
        }
        return false;
    }
    
    @MainActor
    private func handle(action: BindableAction) {
        logger.info("Hotkey triggered for action: \(action.name)")

        switch action {
        case .quickSnip:
            Task { @MainActor in
                await appOrchestra.takeSnip()
            }
            break
        default:
            break
        }
    }
    
    @MainActor
    private func registerKeybinds() {
        stopMonitoring()

        let refcon = Unmanaged.passUnretained(self).toOpaque()

        let eventMask = (1 << CGEventType.keyDown.rawValue)


        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: eventTapCallback,
            userInfo: refcon
        ) else {
            logger.error("Failed to create event tap. Make sure accessibility permissions are granted.")
            return
        }
        
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        
        CGEvent.tapEnable(tap: tap, enable: true)
        self.eventTap = tap
        self.runLoopSource = source
        
        logger.info("Registered keybinds using CGEventTap.")
    }
    
    
    deinit {
        stopMonitoringBridge();
    }
    
    private func stopMonitoringBridge(){
        DispatchQueue.main.async {
            self.stopMonitoring()
        }
    }
    
    @MainActor
    private func stopMonitoring() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        eventTap = nil
        runLoopSource = nil
        logger.info("Stopped keybind monitoring.")
    }
}
