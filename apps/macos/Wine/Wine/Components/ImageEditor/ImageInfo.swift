//
//  ImageInfo.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import SwiftUI

struct ImageInfo: View {
    @State var viewModel: SharedImageEditorViewModel;
    
    var body: some View {
        Group {
            VStack (spacing: 10) {
                Text("Image Info")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)

            }
        }
    }
}

#Preview {
    ImageInfo(viewModel: SharedImageEditorViewModel.preview())
}
