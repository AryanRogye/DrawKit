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
            .position(shapePoint.position)
        
    }
}
