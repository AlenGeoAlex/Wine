// TextAnnotationControls.swift

import SwiftUI

struct TextAnnotationControls: View {
    // Use @Bindable for two-way binding with @Observable objects
    @Bindable var element: TextAnnotation
    
    // Get a sorted list of available font families on the system
    private let availableFonts = NSFontManager.shared.availableFontFamilies.sorted()
    
    var body: some View {
        GroupBox("Text Settings") {
            VStack(alignment: .leading, spacing: 15) {
                
                // --- Text Editor ---
                TextEditor(text: $element.text)
                    .font(.system(size: 14))
                    .frame(height: 100)
                    .scrollContentBackground(.hidden) // Allows custom background
                    .background(Color.black.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )

                Divider()
                
                // --- Font Family and Style Toggles ---
                VStack(spacing: 12) {
                    Picker("Font", selection: $element.fontName) {
                        ForEach(availableFonts, id: \.self) { fontName in
                            Text(fontName).tag(fontName)
                        }
                    }
                    
                    HStack {
                        StyleToggleButton(label: "Bold", systemImage: "bold", isOn: $element.isBold)
                        StyleToggleButton(label: "Italic", systemImage: "italic", isOn: $element.isItalic)
                        StyleToggleButton(label: "Underline", systemImage: "underline", isOn: $element.isUnderline)
                        StyleToggleButton(label: "Strikethrough", systemImage: "strikethrough", isOn: $element.isStrikethrough)
                        Spacer()
                    }
                }
                
                Divider()

                // --- Color and Size ---
                LabeledContent("Text Color") {
                    ColorPicker("Text Color", selection: $element.color, supportsOpacity: true)
                        .labelsHidden()
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(Int(element.fontSize)) pt")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $element.fontSize, in: 8...200)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
        }
    }
}

// A reusable view for the style toggle buttons (Bold, Italic, etc.)
struct StyleToggleButton: View {
    let label: String
    let systemImage: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            Image(systemName: systemImage)
                .font(.body.weight(.bold))
                .frame(width: 32, height: 28)
                .background(isOn ? Color.accentColor : Color.clear)
                .foregroundStyle(isOn ? .white : .primary)
                .contentShape(Rectangle())
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help(label) // Tooltip for accessibility
    }
}

#Preview {
    // Create a sample element for the preview
    let sampleText = TextAnnotation(text: "Hello World", position: .zero)
    
    return GeneralControls(sharedEditorOptions: SharedImageEditorViewModel.preview())
        .onAppear {
            // In a real app, you would select the text element
            // Here we just show the controls directly for previewing
        }
        .frame(width: 300, height: 600)
        .preferredColorScheme(.dark)
        .padding()
}

// A direct preview of just the text controls for easier iteration
#Preview("Text Controls Only") {
     TextAnnotationControls(element: TextAnnotation(text: "Hello World", position: .zero))
        .padding()
        .frame(width: 300)
        .preferredColorScheme(.dark)
}
