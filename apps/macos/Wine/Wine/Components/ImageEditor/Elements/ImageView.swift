//
//  DraggableImageView.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//

import SwiftUI

struct ImageView: View {
    @State var imageElement: ImageElement
    let isInteractive: Bool

    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var zoomScale: CGFloat = 1.0

    var body: some View {
        Image(nsImage: imageElement.imageToRender)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: imageElement.cornerRadius))
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
            .scaleEffect(imageElement.scale * zoomScale)
            .gesture(isInteractive ? magnificationGesture : nil)
            .id(imageElement.imageToRender.hashValue)
            .rotation3DEffect(imageElement.is3DEffectEnabled ? imageElement.get3DRotationAngle() : .zero,
                              axis: imageElement.is3DEffectEnabled ? imageElement.get3DRotationAxis(): (x: 0, y: 0, z: 1),
                              anchor: imageElement.get3DRotationAnchor(),
                              perspective: imageElement.is3DEffectEnabled ? 0.2 : 0
            )
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($zoomScale) { latestGestureScale, state, _ in
                state = latestGestureScale
            }
            .onEnded { finalGestureScale in
                // Apply the final scale to the element's permanent scale
                imageElement.scale *= finalGestureScale
            }
    }
}
