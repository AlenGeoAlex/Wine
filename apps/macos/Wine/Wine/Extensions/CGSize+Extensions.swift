//
//  CGSize+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import Foundation

extension CGSize {
    /// Enables adding two CGSize values together.
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }
}
