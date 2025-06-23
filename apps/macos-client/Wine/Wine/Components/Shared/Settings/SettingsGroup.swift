//
//  SettingsGroup.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI

struct SettingsGroup<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(5)
        .frame(maxWidth: .infinity)
    }
}
