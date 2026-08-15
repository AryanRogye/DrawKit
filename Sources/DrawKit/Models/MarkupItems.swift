//
//  MarkupItems.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import Foundation
import SwiftUI

enum MarkupItems: Hashable {
    case none
    case rectangle(RectanglePoint)
    case circle(CirclePoint)
    case triangle(TrianglePoint)
    case pen(PenStroke)
    
    var color: Color? {
        switch self {
        case .none:
            return nil
        case .rectangle(let shapePoint):
            return shapePoint.color
        case .circle(let shapePoint):
            return shapePoint.color
        case .triangle(let shapePoint):
            return shapePoint.color
        case .pen(let penStroke):
            return penStroke.color
        }
    }
    
    var width: CGFloat? {
        switch self {
        case .rectangle(let rectanglePoint):
            rectanglePoint.width
        case .circle(let circlePoint):
            circlePoint.width
        case .triangle(let trianglePoint):
            trianglePoint.width
        default:
            nil
        }
    }
    
    var height: CGFloat? {
        switch self {
        case .rectangle(let rectanglePoint):
            rectanglePoint.height
        case .circle(let circlePoint):
            circlePoint.height
        case .triangle(let trianglePoint):
            trianglePoint.height
        default:
            nil
        }
    }
    
    var cornerRadius: CGFloat? {
        switch self {
        case .rectangle(let rectanglePoint):
            rectanglePoint.cornerRadius
        case .triangle(let trianglePoint):
            trianglePoint.cornerRadius
        default:
            nil
        }
    }
    
    var strokeColor: Color? {
        switch self {
        case .rectangle(let point):
            point.strokeColor
        case .circle(let point):
            point.strokeColor
        case .triangle(let point):
            point.strokeColor
        default:
            nil
        }
    }
    
    var strokeWidth: CGFloat? {
        switch self {
        case .rectangle(let point):
            point.strokeWidth
        case .circle(let point):
            point.strokeWidth
        case .triangle(let point):
            point.strokeWidth
        default:
            nil
        }
    }
    
    var shapePoint: (any ShapePoint)? {
        switch self {
        case .rectangle(let shapePoint):
            shapePoint
        case .circle(let shapePoint):
            shapePoint
        case .triangle(let shapePoint):
            shapePoint
        default:
            nil
        }
    }
    
    var isShape: Bool {
        switch self {
        case .none:
            false
        case .rectangle:
            true
        case .circle:
            true
        case .triangle:
            true
        case .pen:
            false
        }
    }
    
    var kind: MarkupRawKind {
        switch self {
        case .none:
                .none
        case .rectangle(_):
                .rectangle
        case .circle(_):
                .circle
        case .triangle(_):
                .triangle
        case .pen(_):
                .pen
        }
    }
    
    mutating func setCornerRadius(_ radius: CGFloat) {
        switch self {
        case .rectangle(var rectanglePoint):
            rectanglePoint.cornerRadius = radius
            self = .rectangle(rectanglePoint)
        case .triangle(var trianglePoint):
            trianglePoint.cornerRadius = radius
            self = .triangle(trianglePoint)
        default:
            break
        }
    }
    mutating func setStrokeColor(_ color: Color?) {
        switch self {
        case .rectangle(var point):
            point.strokeColor = color
            self = .rectangle(point)
            
        case .circle(var point):
            point.strokeColor = color
            self = .circle(point)
            
        case .triangle(var point):
            point.strokeColor = color
            self = .triangle(point)
            
        default:
            break
        }
    }
    
    mutating func setOpacity(_ opacity: CGFloat) {
        switch self {
        case .rectangle(var rectanglePoint):
            rectanglePoint.color = rectanglePoint.color.replacingAlpha(with: opacity)
            self = .rectangle(rectanglePoint)
        case .circle(var circlePoint):
            circlePoint.color = circlePoint.color.replacingAlpha(with: opacity)
            self = .circle(circlePoint)
        case .triangle(var trianglePoint):
            trianglePoint.color = trianglePoint.color.replacingAlpha(with: opacity)
            self = .triangle(trianglePoint)
        case .pen(var penStroke):
            penStroke.color = penStroke.color.replacingAlpha(with: opacity)
            self = .pen(penStroke)
        default:
            break
        }
    }
    
    mutating func setStrokeWidth(_ width: CGFloat?) {
        switch self {
        case .rectangle(var point):
            point.strokeWidth = width
            self = .rectangle(point)
            
        case .circle(var point):
            point.strokeWidth = width
            self = .circle(point)
            
        case .triangle(var point):
            point.strokeWidth = width
            self = .triangle(point)
            
        default:
            break
        }
    }
}

public enum MarkupRawKind: String {
    case none = "None"
    case pen = "Pen"
    case rectangle = "Rectangle"
    case circle = "Circle"
    case triangle = "Triangle"
}
