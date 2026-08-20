//
//  DrawCanvas.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI
import LocalShortcuts

public struct DrawCanvas: View {

    private static let viewportCoordinateSpace = "DrawKit.DrawCanvas.viewport"
    
    @Bindable var editor: DrawEditor
    @Binding var save: Bool
    let onSave: (SystemImage?) -> Void
    
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var magnificationStartOffset: CGSize = .zero
    @State private var isMagnifying = false
    @State private var activePenStrokeIndex: Int?
    @State private var eraserGestureState = EraserGestureState()
#if os(macOS)
    @State private var monitor: Any?
#endif
    
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
        onSave: @escaping (SystemImage?) -> Void
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
#if os(macOS)
                    .onAppear {
                        self.monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
                            
                            if let shortcut = LocalShortcuts.Shortcut.from(event: event) {
                                if shortcut == .init(modifier: [], keys: [.escape]) {
                                    self.editor.canvasSelected = nil
                                    self.editor.activeTool = .none
                                }
                                if editor.canvasSelected != nil,
                                   shortcut == .init(modifier: [], keys: [.delete]) {
                                    editor.deleteSelectedItem()
                                }
                            }
                            
                            return event
                        }
                    }
                    .onDisappear {
                        if let monitor {
                            NSEvent.removeMonitor(monitor)
                            self.monitor = nil
                        }
                    }
#endif
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
                    .onChange(of: editor.selectedHoverItem) { oldTool, newTool in
                        if oldTool == .eraser, newTool != .eraser {
                            eraserGestureState.reset()
                            editor.commitHistoryTransaction()
                        }
                        if oldTool == .pen, newTool != .pen {
                            activePenStrokeIndex = nil
                            editor.commitHistoryTransaction()
                        }
                    }
                    .if(editor.selectedHoverItem == .pen) {
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
                                        activePenStrokeIndex = editor.beginPenStroke(
                                            at: startLocation
                                        )
                                    }

                                    guard let index = activePenStrokeIndex else { return }
                                    editor.appendPenPoint(location, at: index)
                                }
                                .onEnded { _ in
                                    activePenStrokeIndex = nil
                                    editor.endPenStroke()
                                }
                        )
                    }
                    .if(editor.selectedHoverItem == .eraser) {
                        $0.simultaneousGesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .named(Self.viewportCoordinateSpace)
                            )
                            .onChanged { value in
                                if eraserGestureState.lastLocation == nil {
                                    editor.beginHistoryTransaction()
                                }
                                let startLocation = canvasLocation(
                                    for: value.startLocation,
                                    canvasSize: geometry.size
                                )
                                let location = canvasLocation(
                                    for: value.location,
                                    canvasSize: geometry.size
                                )
                                let previousLocation = eraserGestureState.advance(
                                    to: location,
                                    startingAt: startLocation
                                )

                                editor.erasePenStrokes(
                                    from: previousLocation,
                                    to: location,
                                    width: editor.lineWidth
                                )
                            }
                            .onEnded { _ in
                                eraserGestureState.reset()
                                editor.commitHistoryTransaction()
                            }
                        )
                    }
                    .onChange(of: editor.activeTool.kind) { oldKind, newKind in
                        if oldKind == .eraser, newKind != .eraser {
                            eraserGestureState.reset()
                            editor.commitHistoryTransaction()
                        }
                        if oldKind == .pen, newKind != .pen {
                            activePenStrokeIndex = nil
                            editor.commitHistoryTransaction()
                        }
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
#if os(macOS)
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
#elseif os(iOS)
            .safeAreaInset(edge: .bottom) {
                if editor.canvasSelected != nil {
                    CanvasInspector(editor: editor)
                        .frame(height: 150)
                        .padding()
                }
            }
#endif
        }
    }

    private func canvasLocation(
        for viewportLocation: CGPoint,
        canvasSize: CGSize
    ) -> CGPoint {
        CanvasNavigation.canvasLocation(
            for: viewportLocation,
            canvasSize: canvasSize,
            scale: scale,
            offset: offset
        )
    }
}

struct EraserGestureState {
    private(set) var lastLocation: CGPoint?

    mutating func advance(
        to location: CGPoint,
        startingAt startLocation: CGPoint
    ) -> CGPoint {
        defer { lastLocation = location }
        return lastLocation ?? startLocation
    }

    mutating func reset() {
        lastLocation = nil
    }
}
