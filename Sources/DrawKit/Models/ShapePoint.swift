//
//  ShapePoint.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

// MARK: - ShapePoint

/// The base protocol that all shapes on the canvas conform to.
/// Contains only properties shared by every shape.
protocol ShapePoint: Identifiable, Hashable {
    /// The unique identifier for the shape.
    var id: UUID { get }

    /// The shape's bounds on the canvas.
    var rect: CGRect { get set }

    /// The shape's primary color.
    ///
    /// - Important: When adding a new `ShapePoint`, update:
    ///   - [Color selection handling](x-source-tag://changeSelectedColorIfNeeded)
    ///   - [Color opacity handling](x-source-tag://markupItems_setOpacity)
    var color: Color { get set }

    /// The rotation applied to the shape on the canvas.
    var rotation: Angle { get set }

    /// Maps the shape from one image coordinate space to another.
    func mapped(
        from oldImageRect: CGRect,
        to newImageRect: CGRect
    ) -> Self
}

/// Helpers and computed properties shared by all `ShapePoint` types.
extension ShapePoint {

    /// The width and height of the shape on the canvas.
    var size: CGSize {
        .init(width: width, height: height)
    }

    /// The width of the shape.
    var width: CGFloat {
        rect.width
    }

    /// The height of the shape.
    var height: CGFloat {
        rect.height
    }

    /// The center position of the shape on the canvas.
    var position: CGPoint {
        CGPoint(
            x: rect.midX,
            y: rect.midY
        )
    }

    /// Returns the shape with its color's alpha replaced by the given opacity.
    mutating func replacingAlpha(with opacity: CGFloat) -> Self {
        self.color = color.replacingAlpha(with: opacity)
        return self
    }

    /// Returns the shape with its rotation replaced by the given angle.
    mutating func replacingRotation(with rotation: Angle) -> Self {
        self.rotation = rotation
        return self
    }
}

// MARK: - CornerRadiusConfigurable

/// Adds corner radius support to shapes that can have rounded corners.
///
/// - Important: When conforming to `CornerRadiusConfigurable`, update:
///   - [MarkupItems.cornerRadius](x-source-tag://markupItems_cornerRadius)
///   - [MarkupItems.setCornerRadius](x-source-tag://markupItems_setCornerRadius)
protocol CornerRadiusConfigurable {
    /// The corner radius applied to the shape.
    var cornerRadius: CGFloat { get set }
}

/// Helpers for shapes that support a corner radius.
extension CornerRadiusConfigurable {

    /// Returns the shape with its corner radius replaced by the given value.
    mutating func replacingCornerRadius(with cornerRadius: CGFloat) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }
}

// MARK: - StrokeConfigurable

/// Adds stroke configuration to shapes that support an outline.
///
/// - Important: When conforming to `StrokeConfigurable`, update:
///   - [MarkupItems.strokeWidth](x-source-tag://markupItems_strokeWidth)
///   - [MarkupItems.strokeColor](x-source-tag://markupItems_strokeColor)
///   - [MarkupItems.setStrokeColor](x-source-tag://markupItems_setStrokeColor)
///   - [MarkupItems.setStrokeWidth](x-source-tag://markupItems_setStrokeWidth)
protocol StrokeConfigurable {
    /// The width of the shape's stroke.
    var strokeWidth: CGFloat? { get set }

    /// The color of the shape's stroke.
    var strokeColor: Color? { get set }
}

/// Helpers for shapes that support stroke configuration.
extension StrokeConfigurable {

    /// Returns the shape with its stroke color replaced by the given color.
    mutating func replacingStrokeColor(with color: Color?) -> Self {
        self.strokeColor = color
        return self
    }

    /// Returns the shape with its stroke width replaced by the given width.
    mutating func replacingStrokeWidth(with width: CGFloat?) -> Self {
        self.strokeWidth = width
        return self
    }
}

/// Helpers for mapping shape bounds between image coordinate spaces.
fileprivate extension CGRect {

    /// Maps this rectangle from the old image bounds into the new image bounds.
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

// MARK: - RectanglePoint
struct RectanglePoint: ShapePoint, CornerRadiusConfigurable, StrokeConfigurable {

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

// MARK: - CirclePoint
struct CirclePoint: ShapePoint, StrokeConfigurable {

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

// MARK: - TrianglePoint
struct TrianglePoint: ShapePoint, CornerRadiusConfigurable, StrokeConfigurable {

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

// MARK: - ArrowPoint
struct ArrowPoint: ShapePoint, CornerRadiusConfigurable, StrokeConfigurable {
    let id: UUID
    var rect: CGRect
    var color: Color
    var rotation: Angle
    var cornerRadius: CGFloat
    var strokeWidth: CGFloat?
    var strokeColor: Color?

    init(id: UUID = UUID(), rect: CGRect, color: Color, strokeWidth: CGFloat?, strokeColor: Color?, cornerRadius: CGFloat, rotation: Angle) {
        self.id = id
        self.rect = rect
        self.color = color
        self.rotation = rotation
        self.cornerRadius = cornerRadius
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }

    func mapped(from oldImageRect: CGRect, to newImageRect: CGRect) -> ArrowPoint {
        ArrowPoint(
            id: id,
            rect: rect.mapped(
                from: oldImageRect,
                to: newImageRect
            ),
            color: color,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            cornerRadius: cornerRadius,
            rotation: rotation,
        )
    }
}
