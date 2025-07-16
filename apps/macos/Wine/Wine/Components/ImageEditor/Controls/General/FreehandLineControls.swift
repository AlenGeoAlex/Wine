//
//  FreehandLineControls.swift
//  Wine
//
//  Created by Alen Alex on 16/07/25.
//

import SwiftUI

struct FreehandLineControls: View {
    @State var element: FreehandLine
    
    var body: some View {
        GroupBox("Drawing Settings") {
            VStack(alignment: .leading, spacing: 12) {
                ColorPicker("Line Color", selection: $element.color)
                
                VStack {
                    Text("Line Width: \(Int(element.lineWidth))")
                    Slider(value: $element.lineWidth, in: 1...50)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
