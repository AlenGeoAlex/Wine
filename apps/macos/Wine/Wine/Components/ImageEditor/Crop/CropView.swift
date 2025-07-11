//
//  CropView.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//
import SwiftUI

struct CropView: View {
    
    var cropViewModel: CropViewModel;
    
    init(cropRect: CGRect, canvasSize: CGSize) {
        self.cropViewModel = CropViewModel(cropRect: cropRect, canvasSize: canvasSize)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.6)
                .mask(
                    Rectangle()
                        .overlay(
                            Rectangle()
                                .frame(width: self.cropViewModel.cropRect.width, height: self.cropViewModel.cropRect.height)
                                .position(
                                    x: self.cropViewModel.cropRect.origin.x + self.cropViewModel.cropRect.width / 2,
                                    y: self.cropViewModel.cropRect.origin.y + self.cropViewModel.cropRect.height / 2
                                )
                                .blendMode(.destinationOut)
                        )
                )

            interactiveCropBox
        }
        .frame(width: self.cropViewModel.canvasSize.width, height: self.cropViewModel.canvasSize.height)
        .contentShape(Rectangle())
    }
    
    private var interactiveCropBox: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .contentShape(Rectangle())
                .gesture(dragGesture(for: .move))

            Rectangle()
                .stroke(Color.white, lineWidth: 1)

            ForEach(CropViewHandle.allCases.filter { $0 != .move }, id: \.self) { handle in
                handleView(at: handle)
            }
        }
        .frame(width: self.cropViewModel.cropRect.width, height: self.cropViewModel.cropRect.height)
        .offset(x: self.cropViewModel.cropRect.origin.x, y: self.cropViewModel.cropRect.origin.y)
    }

    private func handleView(at position: CropViewHandle) -> some View {
        let size: CGFloat = 12
        let tapTargetSize: CGFloat = 24

        return Rectangle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .frame(width: tapTargetSize, height: tapTargetSize)
            .contentShape(Rectangle())
            .position(position.position(in: self.cropViewModel.cropRect.size))
            .gesture(dragGesture(for: position))
    }
    
    private func dragGesture(for handle: CropViewHandle) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                if self.cropViewModel.initialRectOnDrag == nil {
                    self.cropViewModel.initialRectOnDrag = self.cropViewModel.cropRect
                }
                
                guard let initialRect = self.cropViewModel.initialRectOnDrag else { return }
                let newRect = initialRect.update(for: handle, with: value.translation)
                self.self.cropViewModel.cropRect = clamp(rect: newRect)
            }
            .onEnded { _ in
                self.cropViewModel.initialRectOnDrag = nil
            }
    }
    
    private func clamp(rect: CGRect) -> CGRect {
        var clampedRect = rect
        clampedRect.size.width = max(clampedRect.size.width, self.cropViewModel.minSize.width)
        clampedRect.size.height = max(clampedRect.size.height, self.cropViewModel.minSize.height)
        clampedRect.origin.x = max(0, min(clampedRect.origin.x, self.cropViewModel.canvasSize.width - clampedRect.width))
        clampedRect.origin.y = max(0, min(clampedRect.origin.y, self.cropViewModel.canvasSize.height - clampedRect.height))
        clampedRect.size.width = min(clampedRect.size.width, self.cropViewModel.canvasSize.width - clampedRect.origin.x)
        clampedRect.size.height = min(clampedRect.size.height, self.cropViewModel.canvasSize.height - clampedRect.origin.y)
        return clampedRect
    }
}

#Preview {
    CropView(
        cropRect: CGRect(x: 50, y: 50, width: 200, height: 200),
        canvasSize: CGSize(width: 400, height: 400)
    )
}


@Observable class CropViewModel {
    var cropRect: CGRect
    let canvasSize: CGSize
    let minSize = CGSize(width: 50, height: 50)
    var initialRectOnDrag: CGRect?
    
    init(cropRect: CGRect, canvasSize: CGSize) {
        self.cropRect = cropRect
        self.canvasSize = canvasSize
    }
}

enum CropViewHandle : CaseIterable {
    case topLeft, top, topRight, left, right, bottomLeft, bottom, bottomRight, move
    
    func position(in size: CGSize) -> CGPoint {
        switch self {
        case .topLeft: return .zero
        case .top: return CGPoint(x: size.width / 2, y: 0)
        case .topRight: return CGPoint(x: size.width, y: 0)
        case .left: return CGPoint(x: 0, y: size.height / 2)
        case .right: return CGPoint(x: size.width, y: size.height / 2)
        case .bottomLeft: return CGPoint(x: 0, y: size.height)
        case .bottom: return CGPoint(x: size.width / 2, y: size.height)
        case .bottomRight: return CGPoint(x: size.width, y: size.height)
        case .move:         return .zero // Not used for positioning
        }
    }
}
