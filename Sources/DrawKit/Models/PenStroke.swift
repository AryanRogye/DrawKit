//
//  PenStroke.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

struct PenStroke: Identifiable, Hashable {
    let id: UUID
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat

    init() {
        id = UUID()
        points = []
        color = .black
        lineWidth = 1
    }

    init(id: UUID, points: [CGPoint], color: Color, lineWidth: CGFloat) {
        self.id = id
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }

    mutating func replacingAlpha(with opacity: CGFloat) -> Self {
        self.color = color.replacingAlpha(with: opacity)
        return self
    }

    func mapped(
        from oldImageRect: CGRect,
        to newImageRect: CGRect
    ) -> PenStroke {
        let scaleX = newImageRect.width / oldImageRect.width
        let scaleY = newImageRect.height / oldImageRect.height
        let mappedPoints = points.map { point in
            CGPoint(
                x: newImageRect.minX + ((point.x - oldImageRect.minX) * scaleX),
                y: newImageRect.minY + ((point.y - oldImageRect.minY) * scaleY)
            )
        }

        return PenStroke(
            id: id,
            points: mappedPoints,
            color: color,
            lineWidth: lineWidth
        )
    }
}
