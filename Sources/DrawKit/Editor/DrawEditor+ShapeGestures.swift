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
                guard self.selectedItem.kind != .pen,
                      self.selectedItem.kind != .eraser else { return }
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
    
    func rotateGesture(
        for shapePoint: any ShapePoint
    ) -> some Gesture {
        DragGesture(coordinateSpace: .named(CanvasView.coordinateSpaceName))
            .onChanged { value in
                self.handleRotate(
                    shapePoint: shapePoint,
                    value: value
                )
            }
            .onEnded { _ in
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
        
        let dx = value.location.x - center.x
        let dy = value.location.y - center.y
        
        let radians = atan2(dy, dx) + .pi / 2
        var rotation = Angle(radians: radians)
        
        let threshold = 2.0
        
        if let snapAngle = Self.hapticRotations.first(where: {
            rotation.inThreshold(of: $0, threshold: threshold)
        }) {
            rotation = snapAngle
        }
        
        handleRotationHaptic(for: rotation)

        switch items[selection.index] {
        case .circle(var circlePoint):
            circlePoint.rotation = rotation
            items[selection.index] = .circle(circlePoint)
        case .rectangle(var rectanglePoint):
            rectanglePoint.rotation = rotation
            items[selection.index] = .rectangle(rectanglePoint)
        case .triangle(var trianglePoint):
            trianglePoint.rotation = rotation
            items[selection.index] = .triangle(trianglePoint)
        default:
            break
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
        default: break
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
        
        let minimumSize: CGFloat = 5
        let cosine = CGFloat(cos(shapePoint.rotation.radians))
        let sine = CGFloat(sin(shapePoint.rotation.radians))
        let canvasTranslation = value.translation
        let localTranslation = CGSize(
            width: canvasTranslation.width * cosine + canvasTranslation.height * sine,
            height: -canvasTranslation.width * sine + canvasTranslation.height * cosine
        )

        var width = resizeStartRect.width
        var height = resizeStartRect.height
        var localCenterShift = CGSize.zero

        if handle.movesLeft {
            width = max(resizeStartRect.width - localTranslation.width, minimumSize)
            localCenterShift.width = (resizeStartRect.width - width) / 2
        } else if handle.movesRight {
            width = max(resizeStartRect.width + localTranslation.width, minimumSize)
            localCenterShift.width = (width - resizeStartRect.width) / 2
        }

        if handle.movesTop {
            height = max(resizeStartRect.height - localTranslation.height, minimumSize)
            localCenterShift.height = (resizeStartRect.height - height) / 2
        } else if handle.movesBottom {
            height = max(resizeStartRect.height + localTranslation.height, minimumSize)
            localCenterShift.height = (height - resizeStartRect.height) / 2
        }

        let centerShift = CGSize(
            width: localCenterShift.width * cosine - localCenterShift.height * sine,
            height: localCenterShift.width * sine + localCenterShift.height * cosine
        )
        let center = CGPoint(
            x: resizeStartRect.midX + centerShift.width,
            y: resizeStartRect.midY + centerShift.height
        )
        
        var shape = shapePoint
        shape.rect = CGRect(
            x: center.x - width / 2,
            y: center.y - height / 2,
            width: width,
            height: height
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
        default:
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
