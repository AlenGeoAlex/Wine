//
//  ControlsView.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI

struct ControlsView: View {
    @State var viewModel: ImageEditorViewModel;
    
    var body: some View {
        Picker("Tool", selection: $viewModel.currentTool) {
            Text("Select").tag(DrawingTool.select)
            Text("Rectangle").tag(DrawingTool.shape(.rectangle))
            Text("Ellipse").tag(DrawingTool.shape(.ellipse))
            Text("Pen").tag(DrawingTool.freehand(color: .red, lineWidth: 4))
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    ControlsView(viewModel: ImageEditorViewModel(
        capture: Capture(type: .screenshot(ScreenshotOptions.defaultSettings()),
                         ext: "png",
                         filePath: URL(string: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1364&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!
                        )
    ))
}
