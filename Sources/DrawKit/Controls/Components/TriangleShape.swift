//
//  TriangleShape.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

struct TriangleShape: Shape {
    var cornerRadius: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let radius = min(
            cornerRadius,
            min(rect.width, rect.height) / 2
        )
        
        guard radius > 0 else {
            var path = Path()
            
            path.move(to: bottomLeft)
            path.addLine(to: top)
            path.addLine(to: bottomRight)
            path.closeSubpath()
            
            return path
        }
        
        func point(
            from start: CGPoint,
            toward end: CGPoint,
            distance: CGFloat
        ) -> CGPoint {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let length = hypot(dx, dy)
            
            guard length > 0 else { return start }
            
            return CGPoint(
                x: start.x + dx / length * distance,
                y: start.y + dy / length * distance
            )
        }
        
        var path = Path()
        
        // Bottom-left corner
        path.move(
            to: point(
                from: bottomLeft,
                toward: bottomRight,
                distance: radius
            )
        )
        
        path.addQuadCurve(
            to: point(
                from: bottomLeft,
                toward: top,
                distance: radius
            ),
            control: bottomLeft
        )
        
        // Top corner
        path.addLine(
            to: point(
                from: top,
                toward: bottomLeft,
                distance: radius
            )
        )
        
        path.addQuadCurve(
            to: point(
                from: top,
                toward: bottomRight,
                distance: radius
            ),
            control: top
        )
        
        // Bottom-right corner
        path.addLine(
            to: point(
                from: bottomRight,
                toward: top,
                distance: radius
            )
        )
        
        path.addQuadCurve(
            to: point(
                from: bottomRight,
                toward: bottomLeft,
                distance: radius
            ),
            control: bottomRight
        )
        
        path.closeSubpath()
        
        return path
    }
}
