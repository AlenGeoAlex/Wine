//
//  CloudSharingSettings.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI
import FactoryKit
import OSLog

struct CloudSharingSettings: View {
    
    @InjectedObject(\.settingsService) private var settingsService : SettingsService;

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                SettingHeader(heading: SettingsSidebarPages.cloudSharing.rawValue, description: SettingsSidebarPages.cloudSharing.description)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                
                SettingsGroup {
                    HStack {
                        Image(systemName: "cloud.rainbow.half.fill")
                        VStack(alignment: .leading) {
                            Text("Cloud provider").fontWeight(.medium)
                            Text("Configure your image or video storage provider").font(.callout).foregroundColor(.secondary)
                        }
                        Spacer()
                        Picker("", selection: $settingsService.uploadSettings.type) {
                            ForEach(UploadSource.allCases) { type in
                                Text(type.name).tag(type)
                            }
                        }.labelsHidden()
                    }
                    
                    Divider()
                    HStack {
                        Spacer()
                        Text(settingsService.uploadSettings.type.description)
                    }.padding(.top, 4)
                }
                
                Divider()
                
                switch settingsService.uploadSettings.type {
                case .wine(_):
                    SelfHostedWine()
                case .none:
                    EmptyView()
                default:
                    ComingSoon()
                }
            }
            .padding(30)
            .frame(maxWidth: 500)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    var selfHostedWineServer : some View {
        VStack {
            Text("Coming soon")
        }.frame(minWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }

}

#Preview {
    CloudSharingSettings()
}
