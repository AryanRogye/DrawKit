//
//  PenStroke.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

struct PenStroke: Identifiable, Hashable {
    let id: UUID
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    
    init() {
        id = UUID()
        points = []
        color = .black
        lineWidth = 1
    }
    
    init(id: UUID, points: [CGPoint], color: Color, lineWidth: CGFloat) {
        self.id = id
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }
}
