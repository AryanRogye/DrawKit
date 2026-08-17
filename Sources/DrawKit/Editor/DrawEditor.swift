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
    @ObservationIgnored var history: DrawEditorHistory
    
    var items: [MarkupItems] = []
    
    var canvasSelected: CanvasSelection? = nil
    var selectedItem: MarkupItems = .none
    
    internal var resizeStartRect: CGRect?
    internal var dragStartRect: CGRect?
    internal var activeRotationDetent: Angle?
    
    var lineWidth: CGFloat = 1
    
    /// Creates an editor with a bounded, in-memory canvas history.
    ///
    /// - Parameters:
    ///   - image: The source image to annotate.
    ///   - historyLimit: The maximum number of edits that can be undone.
    public init(image: SystemImage, historyLimit: Int = 100) {
        precondition(historyLimit > 0, "historyLimit must be greater than zero")
        self.image = image
        self.history = DrawEditorHistory(limit: historyLimit)
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

        items = items.mapped(from: oldImageRect, to: newImageRect)
        remapHistory(from: oldImageRect, to: newImageRect)
    }
}

extension Array where Element == MarkupItems {
    func mapped(from oldImageRect: CGRect, to newImageRect: CGRect) -> Self {
        map { item in
            switch item {
            case .rectangle(let shapePoint):
                .rectangle(shapePoint.mapped(from: oldImageRect, to: newImageRect))
            case .circle(let shapePoint):
                .circle(shapePoint.mapped(from: oldImageRect, to: newImageRect))
            case .triangle(let shapePoint):
                .triangle(shapePoint.mapped(from: oldImageRect, to: newImageRect))
            case .pen(let stroke):
                .pen(stroke.mapped(from: oldImageRect, to: newImageRect))
            default:
                item
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
