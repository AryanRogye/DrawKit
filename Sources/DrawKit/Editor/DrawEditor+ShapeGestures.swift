//
//  DrawEditor+ShapeGestures.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

extension DrawEditor {
    func dragGesture(
        for shapePoint: any ShapePoint,
        index: Int,
        kind: MarkupRawKind
    ) -> some Gesture {
        DragGesture(coordinateSpace: .named(CanvasView.coordinateSpaceName))
            .onChanged { value in
                guard self.activeTool.kind != .pen,
                      self.activeTool.kind != .eraser else { return }
                self.beginHistoryTransaction()
                self.handleDrag(
                    shapePoint: shapePoint,
                    value: value,
                    index: index,
                    kind: kind
                )
            }
            .onEnded { _ in
                self.dragStartRect = nil
                self.commitHistoryTransaction()
            }
    }
    
    func rotateGesture(
        for shapePoint: any ShapePoint
    ) -> some Gesture {
        DragGesture(coordinateSpace: .named(CanvasView.coordinateSpaceName))
            .onChanged { value in
                self.beginHistoryTransaction()
                self.handleRotate(
                    shapePoint: shapePoint,
                    value: value
                )
            }
            .onEnded { _ in
                self.activeRotationDetent = nil
                self.commitHistoryTransaction()
            }
    }
    
    func resizeGesture(
        for shapePoint: any ShapePoint,
        handle: ResizeHandle
    ) -> some Gesture {
        DragGesture(
            minimumDistance: 0,
            coordinateSpace: .named(CanvasView.coordinateSpaceName)
        )
            .onChanged { value in
                self.beginHistoryTransaction()
                self.handleResize(
                    value: value,
                    shapePoint: shapePoint,
                    handle: handle
                )
            }
            .onEnded { _ in
                self.resizeStartRect = nil
                self.commitHistoryTransaction()
            }
    }
    
    static var hapticRotations: [Angle] = [
        .degrees(0),
        .degrees(45),
        .degrees(90),
        .degrees(135),
        .degrees(180),
        .degrees(225),
        .degrees(270),
        .degrees(315),
        .degrees(360)
    ]
    
    func handleRotate(
        shapePoint: any ShapePoint,
        value: DragGesture.Value
    ) {
        guard let selection = canvasSelected,
              selection.id == shapePoint.id,
              items.indices.contains(selection.index) else { return }
        
        let center = CGPoint(
            x: shapePoint.rect.midX,
            y: shapePoint.rect.midY
        )
        
        let threshold = 2.0
        let rotation = ShapeTransform.rotation(
            around: center,
            toward: value.location,
            detents: Self.hapticRotations,
            threshold: threshold
        )
        
        handleRotationHaptic(for: rotation)

        switch items[selection.index] {
        case .circle(var circlePoint):          items[selection.index] = .circle(circlePoint.replacingRotation(with: rotation))
        case .rectangle(var rectanglePoint):    items[selection.index] = .rectangle(rectanglePoint.replacingRotation(with: rotation))
        case .triangle(var trianglePoint):      items[selection.index] = .triangle(trianglePoint.replacingRotation(with: rotation))
        case .arrow(var arrowPoint):            items[selection.index] = .arrow(arrowPoint.replacingRotation(with: rotation))
        case .none:                             break
        case .pen:                              break
        case .eraser:                           break
        }
    }
    
    func handleDrag(
        shapePoint: any ShapePoint,
        value: DragGesture.Value,
        index: Int,
        kind: MarkupRawKind
    )
    {
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
            if let shape = shape as? RectanglePoint {
                items[index] = .rectangle(shape)
            }
        case .circle:
            if let shape = shape as? CirclePoint {
                items[index] = .circle(shape)
            }
        case .triangle:
            if let shape = shape as? TrianglePoint {
                items[index] = .triangle(shape)
            }
        case .arrow:
            if let shape = shape as? ArrowPoint {
                items[index] = .arrow(shape)
            }
        case .none:
            break
        case .pen:
            break
        case .eraser:
            break
        }
    }
    
    func handleResize(
        value: DragGesture.Value,
        shapePoint: any ShapePoint,
        handle: ResizeHandle
    )
    {
        if resizeStartRect == nil {
            resizeStartRect = shapePoint.rect
        }
        
        guard let resizeStartRect,
              let selection = canvasSelected,
              selection.id == shapePoint.id,
              items.indices.contains(selection.index) else { return }
        
        var shape = shapePoint
        shape.rect = ShapeTransform.resizedRect(
            from: resizeStartRect,
            canvasTranslation: value.translation,
            rotation: shapePoint.rotation,
            handle: handle
        )
        
        switch items[selection.index] {
        case .rectangle:
            if let shape = shape as? RectanglePoint {
                items[selection.index] = .rectangle(shape)
            }
        case .circle:
            if let shape = shape as? CirclePoint {
                items[selection.index] = .circle(shape)
            }
        case .triangle:
            if let shape = shape as? TrianglePoint {
                items[selection.index] = .triangle(shape)
            }
        case .arrow(_):
            if let shape = shape as? ArrowPoint {
                items[selection.index] = .arrow(shape)
            }
        case .none:
            break
        case .pen:
            break
        case .eraser:
            break
        }
    }
}

extension DrawEditor {
    func handleRotationHaptic(for rotation: Angle) {
        let threshold = 2.0
        
        let matchedDetent = Self.hapticRotations.first {
            abs($0.degrees - rotation.degrees) <= threshold
        }
        
        if let matchedDetent {
            if activeRotationDetent != matchedDetent {
                Haptics.performDetentHaptic()
                activeRotationDetent = matchedDetent
            }
        } else {
            activeRotationDetent = nil
        }
    }
}
