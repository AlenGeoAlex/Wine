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

@available(macOS 15.0, *)
struct MenuBarViewOS15 : Scene {
    
    @InjectedObject(\.settingsService) private var settingsService
    @Injected(\.screenshotOrchestra) private var screenshotOrchestra : AppOrchestra;
    @InjectedObject(\.scVideoCapture) private var scVideoCapture: SCVideoCapture
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        MenuBarExtra(AppConstants.appName, systemImage: "camera.filters"){
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
                        scVideoCapture.requestRecordingSource(conf: StreamConfiguration())
                    }
                }.keyboardShortcut(getKeyboardShortcut(for: .quickScreenRecord))
                    .id(scVideoCapture.versionId)
                    .disabled(scVideoCapture.isRecording)
                
                if(scVideoCapture.isRecording){
                    Button("Stop"){
                        Task {
                            if(scVideoCapture.isRecording){
                                scVideoCapture.stopRecording();
                            }else{
                                openWindow(id: AppConstants.WindowConstants.RecorderWindowConstant)
                            }
                        }
                    }.keyboardShortcut(getKeyboardShortcut(for: .screenRecord))
                }else{
                    Button(BindableAction.screenRecord.name){
                        Task {
                            openWindow(id: AppConstants.WindowConstants.RecorderWindowConstant)
                        }
                    }.keyboardShortcut(getKeyboardShortcut(for: .screenRecord))
                }
                
                Divider();
                
                SettingsLink {
                    Text("Settings")
                }
                Button("Transfers"){
                    print("Transfers!")
                }
                Button("Quit"){
                    NSApp.terminate(nil)
                }
            }.id("\(settingsService.appSettings.versionId) "+" \(scVideoCapture.versionId)")
        }
        
        Settings{
            SettingsView()
        }
    }
    
    private func stopRecording(){
        self.scVideoCapture.stopRecording();
    }
    
    
    private func getKeyboardShortcut(for action: BindableAction) -> KeyboardShortcut? {
        let key = settingsService.appSettings.bindings[action, default: .empty];
        return key.swiftUIKeyboardShortcut;
    }

}

struct MenuBarViewLegacy : Scene {
    
    @InjectedObject(\.settingsService) private var settingsService
    @Injected(\.screenshotOrchestra) private var screenshotOrchestra : AppOrchestra;
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        MenuBarExtra(AppConstants.appName, systemImage: "camera.filters"){
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
                
                if #available(macOS 14.0, *) {
                    SettingsLink {
                        Text("Settings")
                    }
                }
                else {
                    Button(action: {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)

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
    
}
