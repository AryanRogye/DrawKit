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
        performHistoryMutation {
            items[selected.index] = .pen(stroke)
        }
    }

    /// - Tag: changeSelectedColorIfNeeded
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

        guard let canvasSelected,
              items.indices.contains(canvasSelected.index) else { return }
        let index = canvasSelected.index
        performHistoryMutation {
            if case .rectangle(let shapePoint) = items[index] {
                let shape = RectanglePoint(
                    id: shapePoint.id,
                    rect: shapePoint.rect,
                    color: color,
                    cornerRadius: shapePoint.cornerRadius,
                    strokeWidth: shapePoint.strokeWidth,
                    strokeColor: shapePoint.strokeColor,
                    rotation: shapePoint.rotation
                )
                items[index] = .rectangle(shape)
            }
            if case .circle(let shapePoint) = items[index] {
                let shape = CirclePoint(
                    id: shapePoint.id,
                    rect: shapePoint.rect,
                    color: color,
                    strokeWidth: shapePoint.strokeWidth,
                    strokeColor: shapePoint.strokeColor,
                    rotation: shapePoint.rotation
                )
                items[index] = .circle(shape)
            }
            if case .triangle(let shapePoint) = items[index] {
                let shape = TrianglePoint(
                    id: shapePoint.id,
                    rect: shapePoint.rect,
                    color: color,
                    strokeWidth: shapePoint.strokeWidth,
                    strokeColor: shapePoint.strokeColor,
                    cornerRadius: shapePoint.cornerRadius,
                    rotation: shapePoint.rotation
                )
                items[index] = .triangle(shape)
            }
            if case .arrow(let shapePoint) = items[index] {
                let shape = ArrowPoint(
                    id: shapePoint.id,
                    rect: shapePoint.rect,
                    color: color,
                    strokeWidth: shapePoint.strokeWidth,
                    strokeColor: shapePoint.strokeColor,
                    cornerRadius: shapePoint.cornerRadius,
                    rotation: shapePoint.rotation
                )
                items[index] = .arrow(shape)
            }
        }
    }
    
    public func select(_ item: MarkupRawKind, with color: Color) {
        // make sure we have a canvas to show our things on
        guard let canvasSize else { return }

        if selectedHoverItem == item {
            selectedItem = .none
            canvasSelected = nil
            return
        }

        selectedHoverItem = item
    }

    public func placeSelectedTool(at location: CGPoint, color: Color) {
        // make sure we have a canvas to show our things on
        guard let canvasSize else { return }
        // center rect
        let center = CGRect(
            x: location.x,
            y: location.y,
            width: 100,
            height: 100
        )

        switch selectedHoverItem {
        case .none:
            return
        case .eraser:
            selectedItem = .eraser
            canvasSelected = nil
        case .pen:
            let pen = PenStroke(
                id: UUID(),
                points: [],
                color: color,
                lineWidth: lineWidth
            )
            selectedItem = .pen(pen)
        case .rectangle:
            selectedItem = .rectangle(defaultSelection.rectSelection.create(at: center, color: color))
            performHistoryMutation {
                items.append(selectedItem)
            }
        case .circle:
            selectedItem = .circle(defaultSelection.circleSelection.create(at: center, color: color))
            performHistoryMutation {
                items.append(selectedItem)
            }
        case .triangle:
            selectedItem = .triangle(defaultSelection.triangleSelection.create(at: center, color: color))
            performHistoryMutation {
                items.append(selectedItem)
            }
        case .arrow:
            selectedItem = .arrow(defaultSelection.arrowSelection.create(at: center, color: color))
            performHistoryMutation {
                items.append(selectedItem)
            }
        }
    }

    func beginPenStroke(at location: CGPoint) -> Int? {
        guard case .pen(let pen) = selectedItem else { return nil }

        beginHistoryTransaction()
        let stroke = PenStroke(
            id: UUID(),
            points: [location],
            color: pen.color,
            lineWidth: pen.lineWidth
        )
        items.append(.pen(stroke))
        return items.count - 1
    }

    func appendPenPoint(_ location: CGPoint, at index: Int) {
        guard items.indices.contains(index),
              case .pen(var stroke) = items[index] else { return }

        stroke.lineWidth = lineWidth
        stroke.points.append(location)
        items[index] = .pen(stroke)
    }

    func endPenStroke() {
        commitHistoryTransaction()
    }

    func deleteSelectedItem() {
        guard let selected = canvasSelected,
              items.indices.contains(selected.index) else {
            canvasSelected = nil
            return
        }

        performHistoryMutation {
            items.remove(at: selected.index)
        }
        canvasSelected = nil
        selectedItem = .none
    }

    func setStrokeColor(_ color: Color?, at index: Int) {
        guard items.indices.contains(index) else { return }
        performHistoryMutation {
            items[index].setStrokeColor(color)
        }
    }

    func setStrokeWidth(_ width: CGFloat?, at index: Int) {
        guard items.indices.contains(index) else { return }
        performHistoryMutation {
            items[index].setStrokeWidth(width)
        }
    }

    func setStroke(width: CGFloat?, color: Color?, at index: Int) {
        guard items.indices.contains(index) else { return }
        performHistoryMutation {
            items[index].setStrokeWidth(width)
            items[index].setStrokeColor(color)
        }
    }

    func setCornerRadius(_ radius: CGFloat, at index: Int) {
        guard items.indices.contains(index) else { return }
        performHistoryMutation {
            items[index].setCornerRadius(radius)
        }
    }

    func setOpacity(_ opacity: CGFloat, at index: Int) {
        guard items.indices.contains(index) else { return }
        performHistoryMutation {
            items[index].setOpacity(opacity)
        }
    }
}
