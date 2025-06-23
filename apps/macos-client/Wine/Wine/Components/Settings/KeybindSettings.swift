//
//  KeybindSettings.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI
import FactoryKit
import OSLog

struct KeybindSettings: View {
    let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "KeybindSettings")
    @InjectedObject(\.settingsService) private var settingsService : SettingsService;
    @State var resetKeybindsAlertIsPresent: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10){
                SettingHeader(heading: SettingsSidebarPages.keybinds.rawValue, description: SettingsSidebarPages.keybinds.description)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                
                ForEach(BindableAction.allCases) { action in
                    HStack {
                        Image(systemName: action.settingIcon)
                        VStack(alignment: .leading) {
                            Text(action.name).fontWeight(.medium)
                            Text(action.settingDescription).font(.callout).foregroundColor(.secondary)
                        }
                        Spacer()
                        KeyboardShortcutCapturer(
                            currentKey: getCurrentBinding(action: action),
                            onKeyPress: { key in
                                settingsService.setKeyBinds(orginalAction: action, key: key)
                            }
                        )
                    }
                }
                
                Divider()
                Button(role: .destructive, action: {
                    resetKeybindsAlertIsPresent = true
                }, label: {
                    Text("Reset")
                        .foregroundColor(.white)
                }).alert("Are you sure to reset all keybinds?", isPresented: $resetKeybindsAlertIsPresent, actions: {
                    Button("Cancel"){
                        resetKeybindsAlertIsPresent = false;
                        logger.trace("User cancelled reset keybinds")
                    }
                    Button("Reset", action: resetAllKeybinds)
                }).frame(maxWidth: .infinity, alignment: .trailing)
                
                Spacer()
            }
            .padding(30)
            .frame(maxWidth: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getCurrentBinding(action: BindableAction) -> Binding<KeyboardKey?> {
        return self.$settingsService.appSettings.bindings[action];
    }
    
    private func resetAllKeybinds(){
        self.settingsService.resetKeybinds()
        logger.trace("User reseted all keybinds")
    }
}

#Preview {
    KeybindSettings()
}
