//
//  ArrowShape.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/19/26.
//

import SwiftUI

/// A conventional upward-pointing arrow with a centered shaft and symmetric
/// arrowhead.
///
/// Its zero-degree orientation matches DrawKit's rotation model, where the top
/// of the canvas is zero degrees.
public struct ArrowShape: Shape {
    /// The shaft width as a proportion of the shape's total width.
    public var shaftWidth: CGFloat

    /// The arrowhead length as a proportion of the shape's total height.
    public var headLength: CGFloat

    /// The radius, in points, applied to the arrow's corners.
    public var cornerRadius: CGFloat

    public init(
        shaftWidth: CGFloat = 0.34,
        headLength: CGFloat = 0.38,
        cornerRadius: CGFloat = 0
    ) {
        self.shaftWidth = shaftWidth
        self.headLength = headLength
        self.cornerRadius = cornerRadius
    }

    nonisolated public func path(in rect: CGRect) -> Path {
        guard rect.width > 0, rect.height > 0 else {
            return Path()
        }

        let clampedShaftWidth = min(max(shaftWidth, 0), 1)
        let clampedHeadLength = min(max(headLength, 0), 1)
        let shaftHalfWidth = rect.width * clampedShaftWidth / 2
        let headBaseY = rect.minY + rect.height * clampedHeadLength

        let vertices = [
            CGPoint(x: rect.midX - shaftHalfWidth, y: rect.maxY),
            CGPoint(x: rect.midX - shaftHalfWidth, y: headBaseY),
            CGPoint(x: rect.minX, y: headBaseY),
            CGPoint(x: rect.midX, y: rect.minY),
            CGPoint(x: rect.maxX, y: headBaseY),
            CGPoint(x: rect.midX + shaftHalfWidth, y: headBaseY),
            CGPoint(x: rect.midX + shaftHalfWidth, y: rect.maxY)
        ]

        return roundedPolygon(
            vertices: vertices,
            radius: max(cornerRadius, 0)
        )
    }
}

private nonisolated func roundedPolygon(
    vertices: [CGPoint],
    radius: CGFloat
) -> Path {
    guard vertices.count > 2 else { return Path() }

    func point(
        from origin: CGPoint,
        toward destination: CGPoint,
        distance: CGFloat
    ) -> CGPoint {
        let dx = destination.x - origin.x
        let dy = destination.y - origin.y
        let edgeLength = hypot(dx, dy)

        guard edgeLength > 0 else { return origin }

        let clampedDistance = min(distance, edgeLength / 2)
        return CGPoint(
            x: origin.x + dx / edgeLength * clampedDistance,
            y: origin.y + dy / edgeLength * clampedDistance
        )
    }

    var path = Path()

    for index in vertices.indices {
        let previousIndex = index == vertices.startIndex
            ? vertices.index(before: vertices.endIndex)
            : vertices.index(before: index)
        let nextIndex = vertices.index(after: index) == vertices.endIndex
            ? vertices.startIndex
            : vertices.index(after: index)
        let vertex = vertices[index]
        let before = point(
            from: vertex,
            toward: vertices[previousIndex],
            distance: radius
        )
        let after = point(
            from: vertex,
            toward: vertices[nextIndex],
            distance: radius
        )

        if index == vertices.startIndex {
            path.move(to: before)
        } else {
            path.addLine(to: before)
        }

        if radius > 0 {
            path.addQuadCurve(to: after, control: vertex)
        } else {
            path.addLine(to: vertex)
        }
    }

    path.closeSubpath()
    return path
}
