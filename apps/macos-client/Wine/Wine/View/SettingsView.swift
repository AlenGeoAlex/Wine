//
//  Settings.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI

struct SettingsView: View {
    
    @State var currentSelectedSidebar : SettingsSidebarPages = .general;
    
    var body: some View {
        NavigationSplitView {
            SettingSidebar(currentSelectedPage: $currentSelectedSidebar)
        } detail: {
            switch currentSelectedSidebar {
            case .general:
                GeneralSettings()
            case .keybinds:
                KeybindSettings()
            case .cloudSharing:
                CloudSharingSettings()
            case .about:
                AboutWineSettings()
            case .list:
                ListCloudUploads()
            }
        }.frame(width: 800, height: 750) 
    }
}

#Preview {
    SettingsView()
}
