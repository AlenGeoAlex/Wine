//
//  CanvasElements.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import SwiftUI

protocol CanvasElement: Identifiable, Hashable {
    var id: UUID { get }
    var position: CGPoint { get set }
    var isSelected: Bool { get set }
}

extension CanvasElement {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
