//
//  CanvasShape.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

struct CanvasShape<S: Shape>: View {
    let shape: S
    let shapePoint: any ShapePoint
    let selected: Bool
    
    var body: some View {
        
        shape
            .fill(shapePoint.color.opacity(1))
            .frame(
                width: shapePoint.width,
                height: shapePoint.height
            )
            .contentShape(.interaction, shape)
            .overlay {
                stroke
            }
        
    }
    
    @ViewBuilder
    var stroke: some View {
        
        let (strokeWidth, strokeColor) = switch shapePoint {
        case let rect as RectanglePoint:
            (rect.strokeWidth, rect.strokeColor)
        case let circle as CirclePoint:
            (circle.strokeWidth, circle.strokeColor)
        case let triangle as TrianglePoint:
            (triangle.strokeWidth, triangle.strokeColor)
        default:
            (nil, nil)
        }

        if let strokeColor, let strokeWidth {
            shape
                .stroke(
                    strokeColor,
                    style: .init(lineWidth: strokeWidth)
                )
                .allowsHitTesting(false)
        }
    }
}
