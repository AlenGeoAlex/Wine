//
//  SolidColorControls.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import SwiftUI

struct SolidColorControls: View {
    @Binding var options: EditorOptions

    let presetColors: [Color] = [
        .black, .white, Color(red: 0.1, green: 0.1, blue: 0.12),
        .blue, .purple, .cyan, .green, .orange, .red
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ColorPicker("Background Color", selection: $options.backgroundColor, supportsOpacity: true)
            
            Text("Presets").foregroundStyle(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                ForEach(presetColors, id: \.self) { color in
                    Button {
                        options.backgroundColor = color
                    } label: {
                        Circle()
                            .fill(color)
                            .overlay(Circle().stroke(Color.secondary.opacity(0.5), lineWidth: 1))
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    SolidColorControls(options: Binding.constant(.init()))
}
