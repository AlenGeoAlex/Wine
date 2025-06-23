//
//  GeneralSettings.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import SwiftUI
import FactoryKit;

struct GeneralSettings: View {
    
    @InjectedObject(\.settingsService) private var settingsService : SettingsService;
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10){
                SettingHeader(heading: SettingsSidebarPages.general.rawValue, description: SettingsSidebarPages.general.description)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                
                SettingsGroup {
                    HStack {
                        Image(systemName: "opticaldisc")
                        VStack(alignment: .leading) {
                            Text("Integrate with Clop").fontWeight(.medium)
                            Text("Optimize the snip or screen records with clop to reduce size if running").font(.callout).foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle(isOn: $settingsService.appSettings.integrateWithClop) { Text("") }
                            .toggleStyle(.checkbox)
                            .disabled(self.isClopPresent ? false : true)
                    }
                    
                    Divider()
                    HStack {
                        Spacer()
                        Text(isClopPresent ? "Defaults to false" : "Clop is not installed")
                    }.padding(.top, 4)
                }
                
                SettingsGroup {
                    HStack {
                        Image(systemName: "eye.slash")
                        VStack(alignment: .leading) {
                            Text("Hide wine if open").fontWeight(.medium)
                            Text("During screenshots or recording, hide the wine window if its open in the front").font(.callout).foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle(isOn: $settingsService.appSettings.hideWineWindows) { Text("") }
                            .toggleStyle(.checkbox)
                    }
                    
                    Divider()
                    HStack {
                        Spacer()
                        Text("Defaults to true")
                    }.padding(.top, 4)
                }
                
                SettingsGroup {
                    HStack {
                        Image(systemName: "xmark.circle")
                        VStack(alignment: .leading) {
                            Text("Clear current wine cache").fontWeight(.medium)
                            Text("Wine temporarily stores snips and recordings to a temp directory for processing and cloud upload (if enabled). Clearing this cache will remove all these files").font(.callout).foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Clear", role: .destructive) {
                            print(1)
                        }
                    }
                    
                    Divider()
                    HStack {
                        Spacer()
                        Text("The default location is /tmp/wine_cache. This will not clear content for today")
                    }.padding(.top, 4)
                }

                Spacer()
            }
            .padding(30)
            .frame(maxWidth: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var isClopPresent : Bool {
        return AppHelpers.isAppInstalled(identifier: AppConstants.Integrations.ClopBundleIdentifier)
    }
}

#Preview {
    GeneralSettings()
}
