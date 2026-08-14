//
//  CanvasView.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

struct CanvasView: View {
    
    @Bindable var editor: DrawEditor
    @Binding var scale: CGFloat
    
    var body: some View {
        ZStack {
            Image(image: editor.image)
                .resizable()
                .scaledToFit()
                .onTapGesture {
                    editor.canvasSelected = nil
                }
            
            ForEach(Array(editor.items.enumerated()), id: \.offset) { index, item in
                switch item {
                case .circle(let shapePoint):
                    circle(shapePoint, index: index)
                        .onTapGesture { editor.canvasSelected = .init(index: index, id: shapePoint.id) }
                case .rectangle(let shapePoint):
                    rectangle(shapePoint, index: index)
                        .onTapGesture { editor.canvasSelected = .init(index: index, id: shapePoint.id)  }
                case .triangle(let shapePoint):
                    triangle(shapePoint, index: index)
                        .onTapGesture { editor.canvasSelected = .init(index: index, id: shapePoint.id) }
                case .pen(let stroke):
                    penStroke(stroke, index: index)
                default:
                    EmptyView()
                }
            }
        }

    }
    
    @ViewBuilder
    private func penStroke(_ stroke: PenStroke, index: Int) -> some View {
        let path = penPath(for: stroke)
        let hitTargetWidth = max(stroke.lineWidth, 12 / max(scale, 0.01))

        Canvas { context, _ in
            context.stroke(
                path,
                with: .color(stroke.color),
                lineWidth: stroke.lineWidth
            )
        }
        .contentShape(
            path.strokedPath(StrokeStyle(
                lineWidth: hitTargetWidth,
                lineCap: .round,
                lineJoin: .round
            ))
        )
        .onTapGesture {
            // dont allow selected while selected is pen
            guard editor.selectedItem.kind != .pen else { return }
            editor.canvasSelected = .init(index: index, id: stroke.id)
        }
    }

    private func penPath(for stroke: PenStroke) -> Path {
        var path = Path()

        guard let firstPoint = stroke.points.first else {
            return path
        }

        path.move(to: firstPoint)
        for point in stroke.points.dropFirst() {
            path.addLine(to: point)
        }

        return path
    }
    
    @ViewBuilder
    private func triangle(_ shapePoint: TrianglePoint, index: Int) -> some View {
        let selected: Bool = shapePoint.id == editor.canvasSelected?.id
        
        ZStack {
            CanvasShape(
                shape: TriangleShape(),
                shapePoint: shapePoint,
                selected: selected
            )
            .gesture(editor.dragGesture(for: shapePoint, index: index, kind: .triangle))
            
            resizeHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )
        }
    }
    
    @ViewBuilder
    private func rectangle(_ shapePoint: RectanglePoint, index: Int) -> some View {
        let selected: Bool = shapePoint.id == editor.canvasSelected?.id
        ZStack {
            CanvasShape(
                shape: RoundedRectangle(cornerRadius: shapePoint.cornerRadius),
                shapePoint: shapePoint,
                selected: selected
            )
            .gesture(editor.dragGesture(for: shapePoint, index: index, kind: .rectangle))
            
            resizeHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )
        }
    }
    
    @ViewBuilder
    private func circle(_ shapePoint: CirclePoint, index: Int) -> some View {
        let selected: Bool = shapePoint.id == editor.canvasSelected?.id
        
        ZStack {
            CanvasShape(
                shape: Circle(),
                shapePoint: shapePoint,
                selected: selected
            )
            .gesture(editor.dragGesture(for: shapePoint, index: index, kind: .circle))
            
            resizeHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )
        }
    }
    
    @ViewBuilder
    private func resizeHandles(
        isVisible: Bool,
        shapePoint: any ShapePoint
    ) -> some View {
        if isVisible {
            ForEach(ResizeHandle.allCases) { handle in
                ResizeHandleView(handle: handle, zoomScale: scale)
                    .position(handle.position(in: shapePoint.rect))
                    .gesture(editor.resizeGesture(
                        for: shapePoint,
                        handle: handle
                    ))
            }
        }
    }
}
