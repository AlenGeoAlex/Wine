//
//  ShapeElementControls.swift
//  Wine
//
//  Created by Alen Alex on 16/07/25.
//

import SwiftUI

struct ShapeElementControls: View {
    @State var element: ShapeElement
    
    var body: some View {
        GroupBox("Shape Settings") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Shape Type", selection: $element.shapeType) {
                    ForEach(ShapeType.allCases) { type in
                        Text(type.id).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                ColorPicker("Fill Color", selection: $element.color)

                VStack {
                    Text("Width: \(Int(element.size.width))")
                    Slider(value: $element.size.width, in: 10...500)
                }
                
                VStack {
                    Text("Height: \(Int(element.size.height))")
                    Slider(value: $element.size.height, in: 10...500)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
