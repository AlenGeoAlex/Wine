//
//  GeneralControls.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI

struct GeneralControls: View {
    @State var sharedEditorOptions: SharedImageEditorViewModel;

    var body: some View {
        Group {
            CropEditorControls(viewModel: sharedEditorOptions)
        }
    }
}

#Preview {
    GeneralControls(sharedEditorOptions: SharedImageEditorViewModel.preview())
}
