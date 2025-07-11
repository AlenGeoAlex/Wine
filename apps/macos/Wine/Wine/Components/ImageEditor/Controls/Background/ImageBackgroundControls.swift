//
//  ImageBackgroundControls.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI

struct ImageBackgroundControls: View {
    @Binding var options: EditorOptions

    private let imageSources: [ImageSource] = [
        .preset(path: "background-img-1"),
        .preset(path: "background-img-2"),
        .preset(path: "background-img-3")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Presets").foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(imageSources) { source in
                        ImagePresetButton(
                            source: source,
                            isSelected: options.backgroundImageUrl == source,
                            action: { options.backgroundImageUrl = source }
                        )
                    }
                }
            }.onAppear(perform: {
                if self.options.backgroundImageUrl == nil {
                    self.options.backgroundImageUrl = self.imageSources.first!
                }
            })

            VStack(alignment: .leading) {
                Text("Effects").foregroundStyle(.secondary)
                Slider(value: $options.backgroundImageBlurRadius, in: 0...30) {
                    Text("Blur")
                }
            }
        }
    }
}

enum ImageSource: Hashable, Identifiable {
    case local(name: String)
    case remote(url: URL)
    case preset(path: String)

    var id: String {
        switch self {
        case .local(let name): return "local-\(name)"
        case .remote(let url): return "remote-\(url.absoluteString)"
        case .preset(let path): return "preset-\(path)"
        }
    }
}

// MARK: - Helper View (Corrected)
private struct ImagePresetButton: View {
    let source: ImageSource
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            imageContentView
                .frame(width: 100, height: 60)
                .background(Color.secondary.opacity(0.1))
                .clipped()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var imageContentView: some View {
        switch source {
        case .preset(let path):
            Image(path)
                .resizable()
                .aspectRatio(contentMode: .fill)

        case .local(let name):
            Image(nsImage: NSImage(contentsOf: URL(string: name)!)!)
                .resizable()
                .aspectRatio(contentMode: .fill)

        case .remote(let url):
            AsyncImage(url: url) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
        }
    }

    private var borderColor: Color {
        isSelected ? .accentColor : .secondary.opacity(0.5)
    }

    private var borderWidth: CGFloat {
        isSelected ? 3 : 1
    }
}

#Preview {
    ImageBackgroundControls(options: Binding.constant(.init()))
}
