//
//  GradientControls.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI

struct GradientControls: View {
    @Binding var options: EditorOptions
    
    let presetGradients: [Gradient] = [
        Gradient(colors: [.pink, .purple]),
        Gradient(colors: [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 0.8, green: 0.0, blue: 0.4)]),
        Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.3, green: 0.3, blue: 0.5)]),
        Gradient(colors: [.green, .blue]),
        Gradient(colors: [Color.black, Color(red: 0.2, green: 0.2, blue: 0.2)]),
        Gradient(colors: [Color.cyan, Color(red: 0.6, green: 0.2, blue: 0.1)]),
    ]

    private var startColor: Binding<Color> {
        Binding(
            get: { options.backgroundGradient.stops.first?.color ?? .clear },
            set: { newColor in
                guard !options.backgroundGradient.stops.isEmpty else { return }
                options.backgroundGradient.stops[0].color = newColor
            }
        )
    }

    private var endColor: Binding<Color> {
        Binding(
            get: { options.backgroundGradient.stops.last?.color ?? .clear },
            set: { newColor in
                guard options.backgroundGradient.stops.count > 1 else { return }
                options.backgroundGradient.stops[options.backgroundGradient.stops.count - 1].color = newColor
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Customize").foregroundStyle(.secondary)
            HStack {
                ColorPicker("Start", selection: startColor)
                ColorPicker("End", selection: endColor)
            }
            
            Text("Presets").foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
                ForEach(0..<presetGradients.count, id: \.self) { index in
                    Button {
                        options.backgroundGradient = presetGradients[index]
                    } label: {
                        Rectangle()
                            .fill(LinearGradient(gradient: presetGradients[index], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 40)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.5)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    GradientControls(options: Binding.constant(.init()))
}
