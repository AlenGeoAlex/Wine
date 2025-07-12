//
//  3DControl.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//

import SwiftUI

struct ThreeDimensionControl: View {
    
    @Bindable var sharedEditorOptions: SharedImageEditorViewModel

    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ThreeDimensionControl(
        sharedEditorOptions: SharedImageEditorViewModel.preview()
    )
}
