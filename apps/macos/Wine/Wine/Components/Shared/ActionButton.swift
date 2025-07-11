//
//  ActionButton.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import SwiftUI

struct ActionButton: View {
    
    @State var viewModel: ActionButtonViewModel
    
    init(
        name iconName: String,
        normalColor: Color = .gray,
        hoverColor: Color = .blue,
        onClick: @escaping () -> Void,
        isInteracting: @escaping (Bool) -> Void
    ){
        self.viewModel = ActionButtonViewModel(
            icon: iconName,
            normalColor: normalColor,
            hoverColor: hoverColor,
            onClick: onClick,
            isInteracting: isInteracting
        );
    }
    
    var body: some View {
        Button(
            action: self.viewModel.onClick,
        ){
            Image(systemName: self.viewModel.iconName)
        }
        .buttonStyle(PlainActionButtonStyle(isHovering: self.viewModel.isHovering, normalColor: self.viewModel.normalColor, hoverColor: self.viewModel.hoverColor))
        .onHover { isHovering in
            withAnimation(.easeInOut(duration: 0.15)) { self.viewModel.isHovering = isHovering }
        }
        .onDisappear() {
            self.viewModel.isInteracting(true)
        }
    }
}

@Observable class ActionButtonViewModel {
    let iconName: String
    let normalColor: Color
    let hoverColor: Color
    let onClick: () -> Void
    let isInteracting: (Bool) -> Void
    
    var isHovering: Bool = false
    
    init(
        icon iconName: String,
        normalColor: Color = .blue,
        hoverColor: Color = .gray,
        onClick: @escaping () -> Void,
        isInteracting: @escaping (Bool) -> Void
    ){
        self.iconName = iconName
        self.normalColor = normalColor
        self.hoverColor = hoverColor
        self.onClick = onClick
        self.isInteracting = isInteracting
    }
    

}

struct PlainActionButtonStyle: ButtonStyle {
    var isHovering: Bool
    var normalColor: Color
    var hoverColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20))
            .foregroundColor(isHovering ? hoverColor : normalColor)
            .frame(width: 40, height: 40)
            .scaleEffect(isHovering ? 1.15 : 1.0)
            .contentShape(Rectangle())
    }
}
