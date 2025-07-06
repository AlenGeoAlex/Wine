//
//  SettingSidebar.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI
import FactoryKit

struct SettingSidebar: View {
    
    @Injected(\.settingsService) private var settingsService;
    @Binding private var currentSelectedPage : SettingsSidebarPages;
    
    init(currentSelectedPage: Binding<SettingsSidebarPages>) {
        _currentSelectedPage = currentSelectedPage
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            List(
                getSideBarPages()
                 , selection: $currentSelectedPage) {
                page in
                NavigationLink(value:page) {
                    Label(page.rawValue, systemImage: page.icon)
                }
            }.listStyle(.sidebar)
            
            Spacer()
            
            VStack {
                Image(systemName: "doc.on.doc.fill") // Placeholder for your app icon
                    .font(.largeTitle)
                    .padding(.bottom, 2)
                Text("\(AppConstants.appName) v\(Bundle.main.appVersion)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
    
    private func getSideBarPages() -> [SettingsSidebarPages] {
        if case .wine = self.settingsService.uploadSettings.type {
            return SettingsSidebarPages.allCases
        } else {
            return SettingsSidebarPages.allCases.filter { $0 != .list }
        }
    }
}


#Preview {
    SettingSidebar(currentSelectedPage: Binding.constant(.general))
}
