//
//  DrawEditorControls.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import Foundation
import SwiftUI
import AppKit

@Observable
@MainActor
public final class DrawEditor {

    let image: NSImage
    var canvasSize: CGSize?
    
    var items: [MarkupItems] = []
    
    var canvasSelected: CanvasSelection? = nil
    var selectedItem: MarkupItems = .none
    
    internal var resizeStartRect: CGRect?
    internal var dragStartRect: CGRect?
    
    public init(image: NSImage) {
        self.image = image
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
