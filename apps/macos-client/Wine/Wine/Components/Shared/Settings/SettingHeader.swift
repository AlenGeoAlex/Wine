//
//  SettingHeader.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import SwiftUI

struct SettingHeader: View {
    
    var heading: String;
    var description: String?;
    
    init(heading: String, description: String? = nil) {
        self.heading = heading
        self.description = description
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(heading)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let description = description {
                Text(description)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    
}

#Preview {
    SettingHeader(heading: "General", description: "Some long description which can be used to check how it will render on screens")
}
