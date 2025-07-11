//
//  CanvasElements.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import SwiftUI

protocol CanvasElement: Identifiable {
    var id: UUID { get }
    var position: CGPoint { get set }
    var isSelected: Bool { get set }
}
