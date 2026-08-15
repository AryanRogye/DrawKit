//
//  DrawEditor+Selection.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

extension DrawEditor {
    public func changePenLineWidth(to lineWidth: CGFloat) {
        self.lineWidth = lineWidth

        if case .pen(var pen) = selectedItem {
            pen.lineWidth = lineWidth
            selectedItem = .pen(pen)
        }

        guard let selected = canvasSelected,
              items.indices.contains(selected.index),
              case .pen(var stroke) = items[selected.index] else { return }

        stroke.lineWidth = lineWidth
        items[selected.index] = .pen(stroke)
    }

    public func changeSelectedColorIfNeeded(_ color: Color) {
        if case .pen(let pen) = selectedItem {
            selectedItem = .pen(PenStroke(
                id: pen.id,
                points: [],
                color: color,
                lineWidth: pen.lineWidth
            ))
            return
        }

        guard let canvasSelected else { return }
        let index = canvasSelected.index
        if case .rectangle(let shapePoint) = items[index] {
            let s: RectanglePoint = .init(
                id: shapePoint.id,
                rect: shapePoint.rect,
                color: color,
                cornerRadius: shapePoint.cornerRadius,
                strokeWidth: shapePoint.strokeWidth,
                strokeColor: shapePoint.strokeColor,
                rotation: shapePoint.rotation
            )
            items[index] = .rectangle(s)
        }
        if case .circle(let shapePoint) = items[index] {
            let s: CirclePoint = .init(
                id: shapePoint.id,
                rect: shapePoint.rect,
                color: color,
                strokeWidth: shapePoint.strokeWidth,
                strokeColor: shapePoint.strokeColor,
                rotation: shapePoint.rotation
            )
            items[index] = .circle(s)
        }
        if case .triangle(let shapePoint) = items[index] {
            let s: TrianglePoint = .init(
                id: shapePoint.id,
                rect: shapePoint.rect,
                color: color,
                strokeWidth: shapePoint.strokeWidth,
                strokeColor: shapePoint.strokeColor,
                cornerRadius: shapePoint.cornerRadius,
                rotation: shapePoint.rotation
            )
            items[index] = .triangle(s)
        }
    }
    
    public func select(_ item: MarkupRawKind, with color: Color) {
        // make sure we have a canvas to show our things on
        guard let canvasSize else { return }
        
        // center rect
        let center = CGRect(
            x: canvasSize.width / 2,
            y: canvasSize.height / 2,
            width: image.size.width / 5,
            height: image.size.width / 5
        )
        
        if selectedItem.kind == item {
            selectedItem = .none
            canvasSelected = nil
            return
        }
        
        switch item {
        case .none:
            return
        case .pen:
            let pen = PenStroke(
                id: UUID(),
                points: [],
                color: color,
                lineWidth: lineWidth
            )
            selectedItem = .pen(pen)
        case .rectangle:
            selectedItem = .rectangle(.init(
                rect: center,
                color: color,
                cornerRadius: 0,
                strokeWidth: nil,
                strokeColor: nil,
                rotation: .degrees(0)
            ))
            items.append(selectedItem)
        case .circle:
            selectedItem = .circle(
                .init(
                    rect: center,
                    color: color,
                    strokeWidth: nil,
                    strokeColor: nil,
                    rotation: .degrees(0)
                )
            )
            items.append(selectedItem)
        case .triangle:
            selectedItem = .triangle(
                .init(
                    rect: center,
                    color: color,
                    strokeWidth: nil,
                    strokeColor: nil,
                    cornerRadius: 0,
                    rotation: .degrees(0)
                )
            )
            items.append(selectedItem)
        }
    }
    
}
