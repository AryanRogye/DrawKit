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
    case rectangle(ShapePoint)
    case circle(ShapePoint)
    case triangle(ShapePoint)
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

public enum MarkupRawKind {
    case none
    case pen
    case rectangle
    case circle
    case triangle
}
