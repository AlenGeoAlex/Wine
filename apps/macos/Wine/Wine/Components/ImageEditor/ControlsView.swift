//
//  ControlsView.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI
import Defaults
import Combine
import AppKit
import OSLog

struct ControlsView: View {
    @State var viewModel: SharedImageEditorViewModel;
    @State var controlViewModel: ControlsViewModel = .init();
    
    var body: some View {
        VStack {
            Text("Controls")
                .font(.headline)
                
            TabView {
                Tab("General", systemImage: "gearshape") {
                    GeneralControls(sharedEditorOptions: viewModel)
                }
                Tab("Background", systemImage: "text.below.photo.rtl") {
                    BackgroundControls(sharedEditorOptions: viewModel)
                }
                Tab("OCR", systemImage: "text.bubble"){
                    OCRControl(sharedEditorOptions: viewModel)
                }
            }
            
            Spacer()
            HStack {
                Button {
                    self.viewModel.isCropping.toggle()
                } label: {
                    Image(systemName: "document.on.document")
                    Text("Copy")
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save")
                }
                
                if controlViewModel.cloudEnabled {
                    Button {
                        
                    } label: {
                        Image(systemName: "icloud.and.arrow.up")
                        Text("Cloud")
                    }
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "xmark.circle")
                    Text("Close")
                }
                .background(Color.red.opacity(0.4))
            }.background(Color.gray.opacity(0.2))
                .padding(.bottom, 10)
        }
    }
}

@Observable class ControlsViewModel {
    
    var cloudEnabled: Bool = false;
    private var cancellables : Set<AnyCancellable> = [];
    
    init() {
        Defaults.publisher(.cloudProvider, options: [.initial])
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] change in
                self?.cloudEnabled = change.newValue != CloudProviders.none.id
            })
            .store(in: &cancellables)
    }
    
}

#Preview {
    ControlsView(viewModel: SharedImageEditorViewModel.preview())
}
