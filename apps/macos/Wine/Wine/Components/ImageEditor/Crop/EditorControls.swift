//
//  EditorControls.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//

import SwiftUI

struct CropEditorControls: View {
    
    @State var viewModel: SharedImageEditorViewModel
    
    var body: some View {
        HStack {
            Button(viewModel.isCropping ? "Cancel" : "Crop") {
                viewModel.toggleCropping()
            }
            .keyboardShortcut(viewModel.isCropping ? .cancelAction : .defaultAction)
            
            if viewModel.isCropping {
                Spacer()
                Button("Apply") {
                    viewModel.applyCrop(
                        contentToRender: CanvasContent(viewModel: viewModel, isInteractive: false)
                    )
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}
