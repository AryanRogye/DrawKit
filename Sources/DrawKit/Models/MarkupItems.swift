//
//  MarkupItems.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import Foundation
import SwiftUI

/// - Warning: Do not use `default` in switches over `MarkupItems`.
///   Exhaustive switches ensure new cases must be handled explicitly.

enum MarkupItems: Hashable {
    case none
    case rectangle(RectanglePoint)
    case circle(CirclePoint)
    case triangle(TrianglePoint)
    case arrow(ArrowPoint)
    case pen(PenStroke)
    case eraser

    /// id given just for the `ForEach`
    var id: MarkupItemID {
        switch self {
        case .none:                             .none
        case .eraser:                           .eraser
        case .rectangle(let point):             .markup(point.id)
        case .circle(let point):                .markup(point.id)
        case .triangle(let point):              .markup(point.id)
        case .arrow(let point):                 .markup(point.id)
        case .pen(let stroke):                  .markup(stroke.id)
        }
    }

    var color: Color? {
        switch self {
        case .rectangle(let shapePoint):        return shapePoint.color
        case .circle(let shapePoint):           return shapePoint.color
        case .triangle(let shapePoint):         return shapePoint.color
        case .pen(let penStroke):               return penStroke.color
        case .none:                             return nil
        case .arrow(let shapePoint):            return shapePoint.color
        case .eraser:                           return nil
        }
    }

    var width: CGFloat? {
        switch self {
        case .rectangle(let rectanglePoint):    rectanglePoint.width
        case .circle(let circlePoint):          circlePoint.width
        case .triangle(let trianglePoint):      trianglePoint.width
        case .none:                             nil
        case .arrow(let arrowPoint):            arrowPoint.width
        case .pen(_):                           nil
        case .eraser:                           nil
        }
    }

    var height: CGFloat? {
        switch self {
        case .rectangle(let rectanglePoint):    rectanglePoint.height
        case .circle(let circlePoint):          circlePoint.height
        case .triangle(let trianglePoint):      trianglePoint.height
        case .none:                             nil
        case .arrow(let arrowPoint):            arrowPoint.height
        case .pen(_):                           nil
        case .eraser:                           nil
        }
    }

    /// - Tag: markupItems_cornerRadius
    var cornerRadius: CGFloat? {
        switch self {
        case .rectangle(let rectanglePoint):    rectanglePoint.cornerRadius
        case .triangle(let trianglePoint):      trianglePoint.cornerRadius
        case .arrow(let arrowPoint):            arrowPoint.cornerRadius
        case .none:                             nil
        case .circle(_):                        nil
        case .pen(_):                           nil
        case .eraser:                           nil
        }
    }

    /// - Tag: markupItems_strokeColor
    var strokeColor: Color? {
        switch self {
        case .rectangle(let point):             point.strokeColor
        case .circle(let point):                point.strokeColor
        case .triangle(let point):              point.strokeColor
        case .arrow(let point):                 point.strokeColor
        case .none:                             nil
        case .pen(_):                           nil
        case .eraser:                           nil
        }
    }

    /// - Tag: markupItems_strokeWidth
    var strokeWidth: CGFloat? {
        switch self {
        case .rectangle(let point):             point.strokeWidth
        case .circle(let point):                point.strokeWidth
        case .triangle(let point):              point.strokeWidth
        case .arrow(let point):                 point.strokeWidth
        case .none:                             nil
        case .pen:                              nil
        case .eraser:                           nil
        }
    }

    var shapePoint: (any ShapePoint)? {
        switch self {
        case .rectangle(let shapePoint):        shapePoint
        case .circle(let shapePoint):           shapePoint
        case .triangle(let shapePoint):         shapePoint
        case .arrow(let shapePoint):            shapePoint
        case .none:                             nil
        case .pen(_):                           nil
        case .eraser:                           nil
        }
    }

    var isShape: Bool {
        switch self {
        case .none:                             false
        case .rectangle:                        true
        case .circle:                           true
        case .triangle:                         true
        case .arrow:                            true
        case .pen:                              false
        case .eraser:                           false
        }
    }

    var kind: MarkupRawKind {
        switch self {
        case .none:                             .none
        case .rectangle:                        .rectangle
        case .circle:                           .circle
        case .triangle:                         .triangle
        case .arrow:                            .arrow
        case .pen:                              .pen
        case .eraser:                           .eraser
        }
    }

    /// - Tag: markupItems_setCornerRadius
    mutating func setCornerRadius(_ radius: CGFloat) {
        switch self {
        case .rectangle(var rectanglePoint):    self = .rectangle(rectanglePoint.replacingCornerRadius(with: radius))
        case .triangle(var trianglePoint):      self = .triangle(trianglePoint.replacingCornerRadius(with: radius))
        case .arrow(var arrowPoint):            self = .arrow(arrowPoint.replacingCornerRadius(with: radius))
        case .none:                             break
        case .circle:                           break
        case .pen:                              break
        case .eraser:                           break
        }
    }

    /// - Tag: markupItems_setStrokeColor
    mutating func setStrokeColor(_ color: Color?) {
        switch self {
        case .rectangle(var point):             self = .rectangle(point.replacingStrokeColor(with: color))
        case .circle(var point):                self = .circle(point.replacingStrokeColor(with: color))
        case .triangle(var point):              self = .triangle(point.replacingStrokeColor(with: color))
        case .arrow(var point):                 self = .arrow(point.replacingStrokeColor(with: color))
        case .none:                             break
        case .pen:                              break
        case .eraser:                           break
        }
    }

    /// - Tag: markupItems_setStrokeWidth
    mutating func setStrokeWidth(_ width: CGFloat?) {
        switch self {
        case .rectangle(var point):             self = .rectangle(point.replacingStrokeWidth(with: width))
        case .circle(var point):                self = .circle(point.replacingStrokeWidth(with: width))
        case .triangle(var point):              self = .triangle(point.replacingStrokeWidth(with: width))
        case .arrow(var point):                 self = .arrow(point.replacingStrokeWidth(with: width))
        case .none:                             break
        case .pen:                              break
        case .eraser:                           break
        }
    }

    /// - Tag: markupItems_setOpacity
    mutating func setOpacity(_ opacity: CGFloat) {
        switch self {
        case .rectangle(var rectanglePoint):    self = .rectangle(rectanglePoint.replacingAlpha(with: opacity))
        case .circle(var circlePoint):          self = .circle(circlePoint.replacingAlpha(with: opacity))
        case .triangle(var trianglePoint):      self = .triangle(trianglePoint.replacingAlpha(with: opacity))
        case .pen(var penStroke):               self = .pen(penStroke.replacingAlpha(with: opacity))
        case .arrow(var arrowPoint):            self = .arrow(arrowPoint.replacingAlpha(with: opacity))
        case .none:                             break
        case .eraser:                           break
        }
    }
}

enum MarkupItemID: Hashable {
    case none
    case eraser
    case markup(UUID)
}

public enum MarkupRawKind: String {
    case none = "None"
    case pen = "Pen"
    case rectangle = "Rectangle"
    case circle = "Circle"
    case triangle = "Triangle"
    case eraser = "Eraser"
    case arrow = "Arrow"
}
