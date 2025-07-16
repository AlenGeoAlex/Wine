//
//  ImageElementControls.swift
//  Wine
//
//  Created by Alen Alex on 16/07/25.
//

import SwiftUI

struct ImageElementControls: View {
    @Bindable var element: ImageElement
    @State var viewModel: SharedImageEditorViewModel
    
    // Grid layout for direction buttons
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        GroupBox("Image Settings") {
            VStack(alignment: .leading, spacing: 14) {
                
                // --- Info Section ---
                LabeledContent("File") {
                    Text(viewModel.captures[element.id]?.filePath.lastPathComponent ?? "N/A")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                LabeledContent("Position", value: "(\(Int(element.position.x)), \(Int(element.position.y)))")

                Divider()

                // --- Sliders Section ---
                VStack(spacing: 14) {
                    VStack {
                        Text("Scale: \(element.scale, specifier: "%.2f")x")
                        Slider(value: $element.scale, in: 0.1...3.0)
                    }
                    VStack {
                        Text("Corner Radius: \(Int(element.cornerRadius))")
                        Slider(value: $element.cornerRadius, in: 0...100)
                    }
                }
                
                Divider()

                // --- 3D Effect Section ---
                VStack(alignment: .leading, spacing: 10) {
                    // Use the default macOS checkbox style by not specifying a toggleStyle
                    Toggle("Enable 3D Effect", isOn: $element.is3DEffectEnabled.animation())
                    
                    if element.is3DEffectEnabled {
                        Text("Perspective Direction")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Perspective3DDirection.allCases) { direction in
                                Button {
                                    element.perspective3DDirection = direction
                                } label: {
                                    // Only show the icon, no text
                                    Image(systemName: direction.systemImageName)
                                }
                                // Apply our custom button style
                                .buttonStyle(DirectionButtonStyle(isSelected: element.perspective3DDirection == direction))
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            // Add padding inside the GroupBox for better spacing
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
        }
    }
}

struct DirectionButtonStyle: ButtonStyle {
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.black.opacity(0.25))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
