//
//  DrawCanvas.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

public struct DrawCanvas: View {
    
    @Bindable var editor: DrawEditor
    @Binding var save: Bool
    let onSave: (NSImage?) -> Void
    
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var zoomAnchor: UnitPoint = .center
    @State private var isMagnifying = false
    
    public init(
        editor: DrawEditor,
    ) {
        self.editor = editor
        self._save = .constant(false)
        self.onSave = { _ in }
    }
    
    public init(
        editor: DrawEditor,
        save: Binding<Bool> = .constant(false),
        onSave: @escaping (NSImage?) -> Void
    ) {
        self.editor = editor
        self._save = save
        self.onSave = onSave
    }
    
    public var body: some View {
        GeometryReader { geometry in
            CanvasView(editor: editor, scale: $scale)
                .saveView(
                    save: $save,
                    canvasSize: geometry.size,
                    imageSize: editor.image.size,
                    onSave: onSave
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(Path(CanvasHelpers.fittedImageRect(imageSize: editor.image.size, in: geometry.size)))
                .scaleEffect(scale, anchor: zoomAnchor)
                .offset(offset)
                .onAppear {
                    editor.canvasSize = geometry.size
                }
                .canvasNavigationGestures(
                    scale: $scale,
                    offset: $offset,
                    lastScale: $lastScale,
                    zoomAnchor: $zoomAnchor,
                    isMagnifying: $isMagnifying,
                    canvasSize: geometry.size
                )
        }
    }
    
}
