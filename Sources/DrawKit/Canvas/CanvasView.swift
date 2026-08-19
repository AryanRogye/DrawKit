//
//  CanvasView.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

struct CanvasView: View {

    static let coordinateSpaceName = "DrawKit.CanvasView.canvas"

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

            ForEach(Array(editor.items.enumerated()), id: \.element.id) { index, item in
                switch item {
                case .circle(let shapePoint):
                    circle(shapePoint, index: index)
                        .onTapGesture {
                            selectItem(at: index, id: shapePoint.id)
                        }
                case .rectangle(let shapePoint):
                    rectangle(shapePoint, index: index)
                        .onTapGesture {
                            selectItem(at: index, id: shapePoint.id)
                        }
                case .triangle(let shapePoint):
                    triangle(shapePoint, index: index)
                        .onTapGesture {
                            selectItem(at: index, id: shapePoint.id)
                        }
                case .arrow(let shapePoint):
                    arrow(shapePoint, index: index)
                        .onTapGesture {
                            selectItem(at: index, id: shapePoint.id)
                        }
                case .pen(let stroke):
                    penStroke(stroke, index: index)
                case .none:
                    EmptyView()
                case .eraser:
                    EmptyView()
                }
            }
        }
        .coordinateSpace(name: Self.coordinateSpaceName)

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
            selectItem(at: index, id: stroke.id)
        }
    }

    private func selectItem(at index: Int, id: UUID) {
        guard editor.selectedItem.kind != .pen,
              editor.selectedItem.kind != .eraser else { return }
        editor.canvasSelected = .init(index: index, id: id)
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
                shape: TriangleShape(cornerRadius: shapePoint.cornerRadius),
                shapePoint: shapePoint,
                selected: selected
            )
            .gesture(editor.dragGesture(for: shapePoint, index: index, kind: .triangle))

            rotateHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )

            resizeHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )
        }
        .frame(width: shapePoint.width, height: shapePoint.height)
        .rotationEffect(shapePoint.rotation)
        .position(shapePoint.position)
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

            rotateHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )

            resizeHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )
        }
        .frame(width: shapePoint.width, height: shapePoint.height)
        .rotationEffect(shapePoint.rotation)
        .position(shapePoint.position)
    }

    @ViewBuilder
    private func arrow(_ shapePoint: ArrowPoint, index: Int) -> some View {
        let selected: Bool = shapePoint.id == editor.canvasSelected?.id

        ZStack {
            CanvasShape(
                shape: ArrowShape(cornerRadius: shapePoint.cornerRadius),
                shapePoint: shapePoint,
                selected: selected
            )
            .gesture(editor.dragGesture(for: shapePoint, index: index, kind: .arrow))


            rotateHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )

            resizeHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )
        }
        .frame(width: shapePoint.width, height: shapePoint.height)
        .rotationEffect(shapePoint.rotation)
        .position(shapePoint.position)
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

            rotateHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )

            resizeHandles(
                isVisible: selected,
                shapePoint: shapePoint
            )
        }
        .frame(width: shapePoint.width, height: shapePoint.height)
        .rotationEffect(shapePoint.rotation)
        .position(shapePoint.position)
    }

    @ViewBuilder
    private func rotateHandles(
        isVisible: Bool,
        shapePoint: any ShapePoint
    ) -> some View {
        if isVisible {
            RotateHandleView(zoomScale: scale)
                .position(CGPoint(
                    x: shapePoint.width / 2,
                    y: -15 / max(scale, 0.01)
                ))
                .gesture(editor.rotateGesture(
                    for: shapePoint,
                ))
        }
    }

    @ViewBuilder
    private func resizeHandles(
        isVisible: Bool,
        shapePoint: any ShapePoint
    ) -> some View {
        if isVisible {
            let localRect = CGRect(origin: .zero, size: shapePoint.size)

            ForEach(ResizeHandle.allCases) { handle in
                ResizeHandleView(handle: handle, zoomScale: scale)
                    .position(handle.position(in: localRect))
                    .gesture(editor.resizeGesture(
                        for: shapePoint,
                        handle: handle
                    ))
            }
        }
    }
}
