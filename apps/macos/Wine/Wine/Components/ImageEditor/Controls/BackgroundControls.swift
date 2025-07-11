//
//  BackgroundControls.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI

struct BackgroundControls: View {
    @Bindable var sharedEditorOptions: SharedImageEditorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("Background Type", selection: $sharedEditorOptions.editorOptions.backgroundType.animation()) {
                ForEach(BackgroundType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            switch sharedEditorOptions.editorOptions.backgroundType {
            case .solid:
                SolidColorControls(options: $sharedEditorOptions.editorOptions)
            case .gradient:
                GradientControls(options: $sharedEditorOptions.editorOptions)
            case .image:
                ImageBackgroundControls(options: $sharedEditorOptions.editorOptions)
            case .none:
                Spacer().frame(height: 1)
            }
            
            Divider()

            // MARK: - General Sizing Controls
            VStack(alignment: .leading, spacing: 15) {
                Text("Padding & Shape").foregroundStyle(.secondary)
                
                Slider(value: $sharedEditorOptions.editorOptions.horizontalPadding, in: 0...200) {
                    Text("Horizontal Padding")
                }
                
                Slider(value: $sharedEditorOptions.editorOptions.cornerRadius, in: 0...100) {
                    Text("Corner Radius")
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    BackgroundControls(
        sharedEditorOptions: SharedImageEditorViewModel.preview()
    )
}
