//
//  DrawEditorControls.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
public final class DrawEditor {

    let image: SystemImage
    var canvasSize: CGSize?
    
    var items: [MarkupItems] = []
    
    var canvasSelected: CanvasSelection? = nil
    var selectedItem: MarkupItems = .none
    
    internal var resizeStartRect: CGRect?
    internal var dragStartRect: CGRect?
    var lineWidth: CGFloat = 1
    
    public init(image: SystemImage) {
        self.image = image
    }
    
    var savedCanvasSelected: CanvasSelection?
    
    public func beforeSave() {
        savedCanvasSelected = canvasSelected
        canvasSelected = nil
    }
    
    public func afterSave() {
        canvasSelected = savedCanvasSelected
        savedCanvasSelected = nil
    }

    func updateCanvasSize(_ newSize: CGSize) {
        defer { canvasSize = newSize }

        guard let oldSize = canvasSize,
              oldSize != newSize else { return }

        let oldImageRect = CanvasHelpers.fittedImageRect(
            imageSize: image.size,
            in: oldSize
        )
        let newImageRect = CanvasHelpers.fittedImageRect(
            imageSize: image.size,
            in: newSize
        )

        guard oldImageRect.width > 0,
              oldImageRect.height > 0 else { return }

        items = items.map { item in
            switch item {
            case .rectangle(let shapePoint):
                return .rectangle(shapePoint.mapped(
                    from: oldImageRect,
                    to: newImageRect
                ))
            case .circle(let shapePoint):
                return .circle(shapePoint.mapped(
                    from: oldImageRect,
                    to: newImageRect
                ))
            case .triangle(let shapePoint):
                return .triangle(shapePoint.mapped(
                    from: oldImageRect,
                    to: newImageRect
                ))
            case .pen(let stroke):
                return .pen(stroke.mapped(
                    from: oldImageRect,
                    to: newImageRect
                ))
            default:
                return item
            }
        }
    }
}

struct CanvasSelection: Equatable {
    let index: Int
    let id: UUID
    
    init(index: Int, id: UUID = UUID()) {
        self.index = index
        self.id = id
    }
}
