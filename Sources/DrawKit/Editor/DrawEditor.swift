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
    var defaultSelection: DefaultSelection
    
    var items: [MarkupItems] = []
    
    var canvasSelected: CanvasSelection? = nil
    var activeTool: MarkupItems = .none
    var selectedHoverItem: MarkupRawKind = .none
    var selectedColor: Color = .black

    internal var resizeStartRect: CGRect?
    internal var dragStartRect: CGRect?
    internal var activeRotationDetent: Angle?


    var lineWidth: CGFloat = 1
    
    /// Creates an editor with a bounded, in-memory canvas history.
    ///
    /// - Parameters:
    ///   - image: The source image to annotate.
    ///   - historyLimit: The maximum number of edits that can be undone.
    ///   - defaultSelection: when a item is selected, this is the default config thats done to it
    public init(image: SystemImage, historyLimit: Int = 100, defaultSelection: DefaultSelection = .init()) {
        precondition(historyLimit > 0, "historyLimit must be greater than zero")
        self.image = image
        self.history = DrawEditorHistory(limit: historyLimit)
        self.defaultSelection = defaultSelection
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
            case .rectangle(let shapePoint):    MarkupItems.rectangle(shapePoint.mapped(from: oldImageRect, to: newImageRect))
            case .circle(let shapePoint):       MarkupItems.circle(shapePoint.mapped(from: oldImageRect, to: newImageRect))
            case .triangle(let shapePoint):     MarkupItems.triangle(shapePoint.mapped(from: oldImageRect, to: newImageRect))
            case .arrow(let shapePoint):        MarkupItems.arrow(shapePoint.mapped(from: oldImageRect, to: newImageRect))
            case .pen(let stroke):              MarkupItems.pen(stroke.mapped(from: oldImageRect, to: newImageRect))
            case .none:                         item
            case .eraser:                       item
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
