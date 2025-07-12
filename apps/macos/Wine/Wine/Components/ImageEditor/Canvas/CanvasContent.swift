//
//  CanvasContent.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//

import SwiftUI

struct CanvasContent: View {
    
    @State var viewModel: SharedImageEditorViewModel
    let isInteractive: Bool
    
    var body: some View {
        ZStack {
            
            CanvasBackgroundView(viewModel: viewModel)

            ForEach(viewModel.editorOptions.elements, id: \.id) { element in
                CanvasElementView(element: element, isInteractive: isInteractive) {
                    selectElement(element)
                }
                .onDeleteCommand(perform: {
                    viewModel.remove(forKey: element.id)
                })
            }
            
            if let activeLine = viewModel.activeFreehandLine {
                CanvasElementView(element: activeLine, isInteractive: false, onSelect: {})
            }
        }.onTapGesture {
            deselectAllElements()
        }
    }
    
    private func selectElement(_ selectedElement: any CanvasElement) {
        viewModel.selectElement(selectedElement)
    }
    
    private func deselectAllElements() {
        viewModel.deselectAllElements()
    }
}

#Preview {
    CanvasContent(viewModel: SharedImageEditorViewModel.preview(), isInteractive: true)
}
