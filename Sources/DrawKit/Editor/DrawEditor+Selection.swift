//
//  DrawEditor+Selection.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

extension DrawEditor {
    public func changeSelectedColorIfNeeded(_ color: Color) {
        guard let canvasSelected else { return }
        let index = canvasSelected.index
        if case .rectangle(let shapePoint) = items[index] {
            let s: ShapePoint = .init(id: shapePoint.id, rect: shapePoint.rect, color: color)
            items[index] = .rectangle(s)
        }
        if case .circle(let shapePoint) = items[index] {
            let s: ShapePoint = .init(id: shapePoint.id, rect: shapePoint.rect, color: color)
            items[index] = .circle(s)
        }
        if case .triangle(let shapePoint) = items[index] {
            let s: ShapePoint = .init(id: shapePoint.id, rect: shapePoint.rect, color: color)
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
        
        switch item {
        case .none:
            return
        case .pen:
            selectedItem = .pen(.init())
        case .rectangle:
            selectedItem = .rectangle(.init(rect: center, color: color))
            items.append(selectedItem)
        case .circle:
            selectedItem = .circle(.init(rect: center, color: color))
            items.append(selectedItem)
        case .triangle:
            selectedItem = .triangle(.init(rect: center, color: color))
            items.append(selectedItem)
        }
    }
    
}
