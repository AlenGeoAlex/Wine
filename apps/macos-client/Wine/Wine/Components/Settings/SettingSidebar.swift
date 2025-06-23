//
//  SettingSidebar.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI

struct SettingSidebar: View {
    
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
            
            List(SettingsSidebarPages.allCases, selection: $currentSelectedPage) {
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
}


#Preview {
    SettingSidebar(currentSelectedPage: Binding.constant(.general))
}
