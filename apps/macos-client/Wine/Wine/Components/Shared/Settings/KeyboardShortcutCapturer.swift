//
//  KeyboardShortcutCapturer.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI
import OSLog
import AppKit
import Foundation

struct KeyboardShortcutCapturer: View {
    
    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "KeyboardShortcutCapturer")
    
    @Binding var currentKey : KeyboardKey?;
    let onKeyPress : (KeyboardKey) -> Void
    @State var isListeningForKeyPresses : Bool = false;
    @State var clickEventMonitor : Any?;
    @State var confirmCancel : Bool = false;
    

    var body: some View {
        Button(action: {
            handleButtonClick();
        }, label: {
            buttonText
        }).alert(
            "Are you sure that you want to cancel the keybind recording",
            isPresented: $confirmCancel) {
                Button("No") {
                    self.confirmCancel = false
                    logger.debug( "User cancelled keybind recording cancellations")
                }
                Button("Yes") {
                    self.confirmCancel = false
                    self.removeMonitor();
                }
                Button("Reset", role: .destructive){
                    self.confirmCancel = false
                    self.reset();
                }
            }
    }
    
    private func handleButtonClick(){
        if(isListeningForKeyPresses && self.clickEventMonitor != nil){
            logger.debug("Duplicate click detectecd for key record, ingoring event")
            return;
        }
        
        self.isListeningForKeyPresses = true;
        self.confirmCancel = false;
        if(self.clickEventMonitor != nil){
            logger.warning("This should not happen, but detected a tangling click event monitor")
            return;
        }
        
        self.clickEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            event in
            
            logger.info("Detected key press as \(event.keyCode) and \(event.modifierFlags.symbolicRepresentation)")
            if(event.keyCode == 53) // Escape
            {
                self.confirmCancel = true;
                return event;
            }
            
            guard let character = event.charactersIgnoringModifiers?.first else {
                logger.warning("Failed to get a valid character from event")
                return event;
            }
            let relevantFlags: NSEvent.ModifierFlags = [.command, .option, .control, .shift]
            let eventModifiers = event.modifierFlags.intersection(relevantFlags)
            let finalKey = KeyboardKey(key: character, modifiers: eventModifiers);
            onKeyPress(finalKey);
            self.removeMonitor()
            return nil;
        });
    }
    
    private func reset(){
        onKeyPress(.empty);
        self.removeMonitor()
    }
    
    private func removeMonitor(){
        self.isListeningForKeyPresses = false;
        guard let monitor = self.clickEventMonitor else {
            logger.warning("Found no monitor to clean up")
            return;
        }
        
        NSEvent.removeMonitor(monitor);
        self.clickEventMonitor = nil;
        logger.info("Cleaned up keybind monitor")
    }
    
    private var buttonText : Text {
        if(isListeningForKeyPresses)
        {
            return Text("Press any key")
                .foregroundColor(.red);
        }
        
        guard let currentKey = currentKey else {
            return Text("No key set");
        }
        
        return Text(currentKey.displayText);
    }
    
}

#Preview {
    KeyboardShortcutCapturer(
        currentKey: Binding.constant(nil),
        onKeyPress: {_ in}
    )
}
