//
//  CanvasShape.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

struct CanvasShape<S: Shape>: View {
    let shape: S
    let shapePoint: ShapePoint
    let selected: Bool
    
    var body: some View {
        
        shape
            .fill(shapePoint.color.opacity(1))
            .frame(
                width: shapePoint.width,
                height: shapePoint.height
            )
            .overlay {
                if selected {
                    shape
                        .stroke(
                            Color.accentColor,
                            style: .init(lineWidth: 2)
                        )
                }
            }
            .position(shapePoint.position)
        
    }
}
