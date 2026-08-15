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
    var rotation: Angle { get set }
    
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
    var color: Color
    var cornerRadius: CGFloat
    var strokeWidth: CGFloat?
    var strokeColor: Color?
    var rotation: Angle
    
    init(id: UUID = UUID(), rect: CGRect, color: Color, cornerRadius: CGFloat, strokeWidth: CGFloat?, strokeColor: Color?, rotation: Angle) {
        self.id = id
        self.rect = rect
        self.color = color
        self.cornerRadius = cornerRadius
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.rotation = rotation
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
            cornerRadius: cornerRadius,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            rotation: rotation
        )
    }
}

struct CirclePoint: ShapePoint {
    
    let id: UUID
    var rect: CGRect
    var color: Color
    var strokeWidth: CGFloat?
    var strokeColor: Color?
    var rotation: Angle
    
    init(id: UUID = UUID(), rect: CGRect, color: Color, strokeWidth: CGFloat?, strokeColor: Color?, rotation: Angle) {
        self.id = id
        self.rect = rect
        self.color = color
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.rotation = rotation
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
            color: color,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            rotation: rotation
        )
    }
}

struct TrianglePoint: ShapePoint {
    
    let id: UUID
    var rect: CGRect
    var color: Color
    var strokeWidth: CGFloat?
    var strokeColor: Color?
    var cornerRadius: CGFloat
    var rotation: Angle
    
    init(id: UUID = UUID(), rect: CGRect, color: Color, strokeWidth: CGFloat?, strokeColor: Color?, cornerRadius: CGFloat, rotation: Angle) {
        self.id = id
        self.rect = rect
        self.color = color
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.cornerRadius = cornerRadius
        self.rotation = rotation
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
            color: color,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            cornerRadius: cornerRadius,
            rotation: rotation
        )
    }
}
