//
//  ShapePoint.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

protocol ShapePoint: Identifiable, Hashable {
    var id: UUID { get }
    var rect: CGRect { get set }
    var color: Color { get }
    
    func mapped(from oldImageRect: CGRect, to newImageRect: CGRect) -> Self
}

extension ShapePoint {
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

private extension CGRect {
    func mapped(
        from oldImageRect: CGRect,
        to newImageRect: CGRect
    ) -> CGRect {
        let scaleX = newImageRect.width / oldImageRect.width
        let scaleY = newImageRect.height / oldImageRect.height
        
        return CGRect(
            x: newImageRect.minX + ((minX - oldImageRect.minX) * scaleX),
            y: newImageRect.minY + ((minY - oldImageRect.minY) * scaleY),
            width: width * scaleX,
            height: height * scaleY
        )
    }
}

struct RectanglePoint: ShapePoint {
    
    let id: UUID
    var rect: CGRect
    let color: Color
    var cornerRadius: CGFloat
    
    init(id: UUID = UUID(), rect: CGRect, color: Color, cornerRadius: CGFloat) {
        self.id = id
        self.rect = rect
        self.color = color
        self.cornerRadius = cornerRadius
    }
    
    func mapped(
        from oldImageRect: CGRect,
        to newImageRect: CGRect
    ) -> RectanglePoint {
        RectanglePoint(
            id: id,
            rect: rect.mapped(
                from: oldImageRect,
                to: newImageRect
            ),
            color: color,
            cornerRadius: cornerRadius
        )
    }
}

struct CirclePoint: ShapePoint {
    
    let id: UUID
    var rect: CGRect
    let color: Color
    
    init(id: UUID = UUID(), rect: CGRect, color: Color) {
        self.id = id
        self.rect = rect
        self.color = color
    }
    
    func mapped(
        from oldImageRect: CGRect,
        to newImageRect: CGRect
    ) -> CirclePoint {
        CirclePoint(
            id: id,
            rect: rect.mapped(
                from: oldImageRect,
                to: newImageRect
            ),
            color: color
        )
    }
}

struct TrianglePoint: ShapePoint {
    
    let id: UUID
    var rect: CGRect
    let color: Color
    
    init(id: UUID = UUID(), rect: CGRect, color: Color) {
        self.id = id
        self.rect = rect
        self.color = color
    }
    
    func mapped(
        from oldImageRect: CGRect,
        to newImageRect: CGRect
    ) -> TrianglePoint {
        TrianglePoint(
            id: id,
            rect: rect.mapped(
                from: oldImageRect,
                to: newImageRect
            ),
            color: color
        )
    }
}
