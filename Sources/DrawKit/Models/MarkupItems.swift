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
    
    var shapePoint: (any ShapePoint)? {
        switch self {
        case .none:
            nil
        case .rectangle(let shapePoint):
            shapePoint
        case .circle(let shapePoint):
            shapePoint
        case .triangle(let shapePoint):
            shapePoint
        case .pen:
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
}

public enum MarkupRawKind: String {
    case none = "None"
    case pen = "Pen"
    case rectangle = "Rectangle"
    case circle = "Circle"
    case triangle = "Triangle"
}
