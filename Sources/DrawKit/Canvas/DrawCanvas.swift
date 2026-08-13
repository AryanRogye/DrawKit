//
//  DrawCanvas.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

public struct DrawCanvas: View {

    private static let viewportCoordinateSpace = "DrawKit.DrawCanvas.viewport"
    
    @Bindable var editor: DrawEditor
    @Binding var save: Bool
    let onSave: (NSImage?) -> Void
    
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var magnificationStartOffset: CGSize = .zero
    @State private var isMagnifying = false
    @State private var activePenStrokeIndex: Int?
    
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
        NavigationStack {
            GeometryReader { geometry in
                CanvasView(editor: editor, scale: $scale)
                    .saveView(
                        save: $save,
                        canvasSize: geometry.size,
                        imageSize: editor.image.size,
                        beforeSave: editor.beforeSave,
                        afterSave: editor.afterSave,
                        onSave: onSave
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(Path(CanvasHelpers.fittedImageRect(imageSize: editor.image.size, in: geometry.size)))
                    .scaleEffect(scale)
                    .offset(offset)
                    .onAppear {
                        editor.updateCanvasSize(geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        editor.updateCanvasSize(newSize)
                    }
                    .if(editor.selectedItem.kind == .pen) {
                        $0.simultaneousGesture(
                            DragGesture(coordinateSpace: .named(Self.viewportCoordinateSpace))
                                .onChanged { value in
                                    let startLocation = canvasLocation(
                                        for: value.startLocation,
                                        canvasSize: geometry.size
                                    )
                                    let location = canvasLocation(
                                        for: value.location,
                                        canvasSize: geometry.size
                                    )

                                    if activePenStrokeIndex == nil {
                                        guard case .pen(let pen) = editor.selectedItem else { return }

                                        let stroke = PenStroke(
                                            id: UUID(),
                                            points: [startLocation],
                                            color: pen.color,
                                            lineWidth: pen.lineWidth
                                        )
                                        editor.items.append(.pen(stroke))
                                        activePenStrokeIndex = editor.items.count - 1
                                    }

                                    guard let index = activePenStrokeIndex,
                                          editor.items.indices.contains(index),
                                          case .pen(var stroke) = editor.items[index] else { return }

                                    stroke.points.append(location)
                                    editor.items[index] = .pen(stroke)
                                }
                                .onEnded { _ in
                                    activePenStrokeIndex = nil
                                }
                        )
                    }
                    .canvasNavigationGestures(
                        scale: $scale,
                        offset: $offset,
                        lastScale: $lastScale,
                        magnificationStartOffset: $magnificationStartOffset,
                        isMagnifying: $isMagnifying,
                        canvasSize: geometry.size
                    )
            }
            .coordinateSpace(name: Self.viewportCoordinateSpace)
            .inspector(isPresented: Binding(
                get: { editor.canvasSelected != nil },
                set: { isPresented in
                    if !isPresented {
                        editor.canvasSelected = nil
                    }
                }
            )) {
                CanvasInspector(editor: editor)
            }
        }
    }

    private func canvasLocation(
        for viewportLocation: CGPoint,
        canvasSize: CGSize
    ) -> CGPoint {
        let canvasCenter = CGPoint(
            x: canvasSize.width / 2,
            y: canvasSize.height / 2
        )
        let safeScale = max(scale, 0.01)

        return CGPoint(
            x: canvasCenter.x
                + (viewportLocation.x - canvasCenter.x - offset.width) / safeScale,
            y: canvasCenter.y
                + (viewportLocation.y - canvasCenter.y - offset.height) / safeScale
        )
    }
}
