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
            Image(nsImage: editor.image)
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
                default:
                    EmptyView()
                }
            }
        }

    }
    
    @ViewBuilder
    private func triangle(_ shapePoint: ShapePoint, index: Int) -> some View {
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
    private func rectangle(_ shapePoint: ShapePoint, index: Int) -> some View {
        let selected: Bool = shapePoint.id == editor.canvasSelected?.id
        ZStack {
            CanvasShape(
                shape: Rectangle(),
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
    private func circle(_ shapePoint: ShapePoint, index: Int) -> some View {
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
        shapePoint: ShapePoint
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
