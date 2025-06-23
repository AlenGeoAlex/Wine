//
//  MenuBar.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import SwiftUI
import Foundation
import AppKit
import FactoryKit;


struct MenuBarView : Scene {
    
    @InjectedObject(\.settingsService) private var settingsService
    @Injected(\.screenshotOrchestra) private var screenshotOrchestra : AppOrchestra;    
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        MenuBarExtra(AppConstants.appName, systemImage: "rainbow"){
            Group{
                Button(BindableAction.quickSnip.name){
                    Task {
                        print("Quick Snip!")
                        await screenshotOrchestra.takeSnip()
                    }
                }.keyboardShortcut(getKeyboardShortcut(for: .quickSnip));
                
                Button(BindableAction.snip.name){
                    print("Snip!")
                }.keyboardShortcut(getKeyboardShortcut(for: .snip));
                
                Divider();
                
                Button(BindableAction.quickScreenRecord.name){
                    Task {
                        openWindow(id: AppConstants.WindowConstants.RecorderWindowConstant)
                        print("Quick Screen Record!")
                    }
                }.keyboardShortcut(getKeyboardShortcut(for: .quickScreenRecord))
                    .disabled(!isScreenSharingEnabled)
                
                Button(BindableAction.screenRecord.name){
                    print("Screen Record")
                }.keyboardShortcut(getKeyboardShortcut(for: .screenRecord))
                    .disabled(!isScreenSharingEnabled);
                
                Divider();
                
                if #available(macOS 14.0, *) {
                    SettingsLink {
                        Text("Settings")
                    }
                }
                else {
                    Button(action: {
                        if #available(macOS 13.0, *) {
                            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        }
                        else {
                            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                        }
                    }, label: {
                        Text("Settings")
                    })
                }
                Button("Transfers"){
                    print("Transfers!")
                }
                Button("Quit"){
                    NSApp.terminate(nil)
                }
            }.id(settingsService.appSettings.versionId)
        }
        
        Settings{
            SettingsView()
        }
    }
    
    private func getKeyboardShortcut(for action: BindableAction) -> KeyboardShortcut? {
        let key = settingsService.appSettings.bindings[action, default: .empty];
        return key.swiftUIKeyboardShortcut;
    }
    
    let isScreenSharingEnabled : Bool = {
        if #available(macOS 15.0, *) {
            return true
        }
        
        return false;
    }()
    
    
}
