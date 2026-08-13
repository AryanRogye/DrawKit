//
//  ShapePoint.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

struct ShapePoint: Identifiable, Hashable {
    let id: UUID
    var rect: CGRect
    var color: Color
    
    init(id: UUID = UUID(), rect: CGRect, color: Color) {
        self.id = id
        self.rect = rect
        self.color = color
    }
    
    mutating func changeColor(_ color: Color) {
        self.color = color
    }
    
    var size: CGSize {
        .init(width: width, height: height)
    }
    
    var width: CGFloat {
        rect.width
    }
    
    var height: CGFloat {
        rect.height
    }
    
    var position: CGPoint {
        CGPoint(
            x: rect.midX,
            y: rect.midY
        )
    }
}
