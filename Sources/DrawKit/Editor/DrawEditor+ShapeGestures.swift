//
//  DrawEditor+ShapeGestures.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

extension DrawEditor {
    func dragGesture(
        for shapePoint: ShapePoint,
        index: Int,
        kind: MarkupRawKind
    ) -> some Gesture {
        DragGesture()
            .onChanged { value in
                self.handleDrag(
                    shapePoint: shapePoint,
                    value: value,
                    index: index,
                    kind: kind
                )
            }
            .onEnded { _ in
                self.dragStartRect = nil
            }
    }
    
    func resizeGesture(
        for shapePoint: ShapePoint,
        handle: ResizeHandle
    ) -> some Gesture {
        DragGesture()
            .onChanged { value in
                self.handleResize(
                    value: value,
                    shapePoint: shapePoint,
                    handle: handle
                )
            }
            .onEnded { _ in
                self.resizeStartRect = nil
            }
    }
    
    func handleDrag(
        shapePoint: ShapePoint,
        value: DragGesture.Value,
        index: Int,
        kind: MarkupRawKind,
    ) {
        if dragStartRect == nil {
            dragStartRect = shapePoint.rect
        }
        
        guard let dragStartRect else { return }
        
        var shape = shapePoint
        shape.rect.origin = CGPoint(
            x: dragStartRect.origin.x + value.translation.width,
            y: dragStartRect.origin.y + value.translation.height
        )
        switch kind {
        case .rectangle:
            items[index] = .rectangle(shape)
        case .circle:
            items[index] = .circle(shape)
        case .triangle:
            items[index] = .triangle(shape)
        default: break
        }
    }
    
    func handleResize(
        value: DragGesture.Value,
        shapePoint: ShapePoint,
        handle: ResizeHandle
    ) {
        if resizeStartRect == nil {
            resizeStartRect = shapePoint.rect
        }
        
        guard let resizeStartRect,
              let selection = canvasSelected,
              selection.id == shapePoint.id,
              items.indices.contains(selection.index) else { return }
        
        let minimumSize: CGFloat = 24
        var minX = resizeStartRect.minX
        var maxX = resizeStartRect.maxX
        var minY = resizeStartRect.minY
        var maxY = resizeStartRect.maxY
        
        if handle.movesLeft {
            minX = min(
                resizeStartRect.minX + value.translation.width,
                resizeStartRect.maxX - minimumSize
            )
        }
        
        if handle.movesRight {
            maxX = max(
                resizeStartRect.maxX + value.translation.width,
                resizeStartRect.minX + minimumSize
            )
        }
        
        if handle.movesTop {
            minY = min(
                resizeStartRect.minY + value.translation.height,
                resizeStartRect.maxY - minimumSize
            )
        }
        
        if handle.movesBottom {
            maxY = max(
                resizeStartRect.maxY + value.translation.height,
                resizeStartRect.minY + minimumSize
            )
        }
        
        var shape = shapePoint
        shape.rect = CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
        
        switch items[selection.index] {
        case .rectangle:
            items[selection.index] = .rectangle(shape)
        case .circle:
            items[selection.index] = .circle(shape)
        case .triangle:
            items[selection.index] = .triangle(shape)
        default:
            break
        }
    }
}
