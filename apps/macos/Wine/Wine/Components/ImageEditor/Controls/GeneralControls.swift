// GeneralControls.swift

import SwiftUI

struct GeneralControls: View {
    @State var sharedEditorOptions: SharedImageEditorViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            toolbarContent
            Divider()
            selectedElementView
        }
        .frame(minWidth: 280) // Give the inspector a good minimum width
    }
    
    @ViewBuilder
    var toolbarContent : some View {
        HStack(spacing: 12) {
            toolButton(for: .select, icon: "cursorarrow")
            toolButton(for: .text, icon: "text.cursor")
            toolButton(for: .shape(.rectangle), icon: "rectangle")
            toolButton(for: .shape(.ellipse), icon: "oval")
            toolButton(for: .freehand(color: .white, lineWidth: 5), icon: "pencil")
            
        }
        .padding(10)
        .frame(maxWidth: .infinity)
    }
    
    /// A helper function to create a styled tool button and avoid repetitive code.
    private func toolButton(for tool: DrawingTool, icon: String) -> some View {
        let isSelected = isToolSelected(tool)
        
        return Button(action: {
            sharedEditorOptions.currentTool = tool
        }) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28, height: 28)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        }
        .buttonStyle(.plain) // Use .plain to allow for custom background styling
    }
    
    /// Checks if a given tool is the currently active one.
    private func isToolSelected(_ tool: DrawingTool) -> Bool {
        switch (sharedEditorOptions.currentTool, tool) {
            // For freehand, we only care that it's the active tool, not its color/width
        case (.freehand, .freehand):
            return true
            // For all other cases, direct comparison works
        default:
            return sharedEditorOptions.currentTool == tool
        }
    }
    
    @ViewBuilder
    var selectedElementView : some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let selectedElements = sharedEditorOptions.selectedElements()
                
                if selectedElements.isEmpty {
                    ContentUnavailableView("No Element Selected", systemImage: "cursorarrow.click.2", description: Text("Select an element on the canvas to see its properties."))
                } else {
                    ForEach(selectedElements, id: \.id) { element in
                        switch element {
                        case let imageElement as ImageElement:
                            ImageElementControls(element: imageElement, viewModel: sharedEditorOptions)
                            
                        case let textElement as TextAnnotation:
                            TextAnnotationControls(element: textElement)
                            
                        case let lineElement as FreehandLine:
                            FreehandLineControls(element: lineElement)
                            
                        case let shapeElement as ShapeElement:
                            ShapeElementControls(element: shapeElement)
                            
                        default:
                            Text("Unknown element type selected.")
                        }
                    }
                }
            }
            .padding()
        }
    }
}
