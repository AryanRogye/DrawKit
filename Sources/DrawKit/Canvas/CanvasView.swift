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
    @State private var userMouseLocation: CGPoint? = nil

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

            if editor.selectedHoverItem != .none {
                Color.clear
                    .contentShape(Rectangle())
                    .highPriorityGesture(
                        SpatialTapGesture(
                            coordinateSpace: .named(Self.coordinateSpaceName)
                        )
                        .onEnded { value in
                            editor.placeSelectedTool(at: value.location)
                        }
                    )
                    .zIndex(1)

                if let userMouseLocation {
                    hoverPreview(
                        for: editor.selectedHoverItem,
                        userMouseLocation: userMouseLocation
                    )
                    .allowsHitTesting(false)
                    .zIndex(2)
                }
            }
        }
        .contentShape(Rectangle())
        .coordinateSpace(name: Self.coordinateSpaceName)
        .onContinuousHover { phase in
            guard editor.selectedHoverItem != .none else {
                return
            }
            switch phase {
            case .active(let location):
                userMouseLocation = location
            case .ended:
                userMouseLocation = nil
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
            selectItem(at: index, id: stroke.id)
        }
    }

    private func selectItem(at index: Int, id: UUID) {
        guard editor.activeTool.kind != .pen,
              editor.activeTool.kind != .eraser else { return }
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
    private func hoverPreview(for item: MarkupRawKind, userMouseLocation: CGPoint) -> some View {
        switch item {
        case .none:
            EmptyView()
        case .pen:
            Circle()
                .stroke(
                    .black,
                    style: .init(lineWidth: 1)
                )
                .frame(width: editor.lineWidth * 20, height: editor.lineWidth * 20)
                .position(userMouseLocation)
        case .rectangle:
            RoundedRectangle(cornerRadius: editor.defaultSelection.rectSelection.cornerRadius)
                .fill(editor.defaultSelection.rectSelection.overrideColor ?? .black)
                .frame(width: 100, height: editor.lineWidth * 100)
                .overlay {
                    RoundedRectangle(cornerRadius: editor.defaultSelection.rectSelection.cornerRadius)
                        .stroke(
                            editor.defaultSelection.rectSelection.strokeColor ?? .clear,
                            style: .init(
                                lineWidth: editor.defaultSelection.rectSelection.strokeWidth ?? 0
                            )
                        )
                }
                .position(userMouseLocation)
        case .circle:
            Circle()
                .fill(editor.defaultSelection.circleSelection.overrideColor ?? .black)
                .frame(width: 100, height: 100)
                .overlay {
                    Circle()
                        .stroke(
                            editor.defaultSelection.circleSelection.strokeColor ?? .clear,
                            style: .init(
                                lineWidth: editor.defaultSelection.circleSelection.strokeWidth ?? 0
                            )
                        )
                }
                .position(userMouseLocation)
        case .triangle:
            TriangleShape(cornerRadius: editor.defaultSelection.triangleSelection.cornerRadius)
                .fill(editor.defaultSelection.triangleSelection.overrideColor ?? .black)
                .frame(width: 100, height: 100)
                .overlay {
                    TriangleShape(cornerRadius: editor.defaultSelection.triangleSelection.cornerRadius)
                        .stroke(
                            editor.defaultSelection.triangleSelection.strokeColor ?? .clear,
                            style: .init(
                                lineWidth: editor.defaultSelection.triangleSelection.strokeWidth ?? 0
                            )
                        )
                }
                .position(userMouseLocation)
        case .arrow:
            ArrowShape(cornerRadius: editor.defaultSelection.arrowSelection.cornerRadius)
                .fill(editor.defaultSelection.arrowSelection.overrideColor ?? .black)
                .frame(width: 100, height: 100)
                .overlay {
                    ArrowShape(cornerRadius: editor.defaultSelection.arrowSelection.cornerRadius)
                        .stroke(
                            editor.defaultSelection.arrowSelection.strokeColor ?? .clear,
                            style: .init(
                                lineWidth: editor.defaultSelection.arrowSelection.strokeWidth ?? 0
                            )
                        )
                }
                .position(userMouseLocation)
        case .eraser:
            Circle()
                .stroke(
                    .black,
                    style: .init(lineWidth: 1)
                )
                .frame(width: editor.lineWidth * 20, height: editor.lineWidth * 20)
                .position(userMouseLocation)
        }
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
