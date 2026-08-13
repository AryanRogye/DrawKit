//
//  CanvasInspector.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/13/26.
//

import SwiftUI

public struct CanvasInspector: View {

    @Bindable var editor: DrawEditor
    
    public init(editor: DrawEditor) {
        self.editor = editor
    }
    
    public var body: some View {
        Form {
            if let selected = editor.canvasSelected,
               editor.items.indices.contains(selected.index) {
                
                Text(editor.items[selected.index].kind.rawValue)
                
                Section("Appearance") {
                    if editor.items[selected.index].color != nil {
                        InspectorOpacitySlider(
                            editor: editor,
                            selected: selected
                        )
                    }
                    if let rectangle = editor.items[selected.index].shapePoint as? RectanglePoint {
                        InspectorCornerRadiusSlider(
                            editor: editor,
                            rectangle: rectangle,
                            selected: selected,
                        )
                    }
                }
                
                if let shapePoint = editor.items[selected.index].shapePoint {
                    Section("Geometry") {
                        LabeledContent("X") { Text("\(shapePoint.rect.minX)") }
                        LabeledContent("Y") { Text("\(shapePoint.rect.minX)") }
                        LabeledContent("Width") { Text("\(shapePoint.width)") }
                        LabeledContent("Height") { Text("\(shapePoint.height)") }
                    }
                }
                
                Button("Delete") {
                    if editor.items.indices.contains(selected.index) {
                        editor.items.remove(at: selected.index)
                    }
                    editor.canvasSelected = nil
                }
            }
        }
        .formStyle(.grouped)
    }
}

private struct InspectorCornerRadiusSlider: View {
    
    @Bindable var editor: DrawEditor
    let rectangle: RectanglePoint
    let selected: CanvasSelection
    
    var body: some View {
        LabeledContent("Corner Radius") {
            Slider(
                value: Binding(
                    get: {
                        guard editor.items.indices.contains(selected.index) else {
                            return 1.0
                        }
                        return rectangle.cornerRadius
                    },
                    set: { radius in
                        guard editor.items.indices.contains(selected.index) else {
                            return
                        }
                        editor.items[selected.index] = .rectangle(
                            .init(
                                id: rectangle.id,
                                rect: rectangle.rect,
                                color: rectangle.color,
                                cornerRadius: radius
                            )
                        )
                    }
                ),
                in: 0...(min(rectangle.rect.width, rectangle.rect.height) / 2),
                step: 1
            )
            .labelsHidden()
            .controlSize(.small)
            .frame(width: 120)
        }
    }
}

private struct InspectorOpacitySlider: View {
    
    @Bindable var editor: DrawEditor
    let selected: CanvasSelection
    
    var body: some View {
        LabeledContent("Opacity") {
            Slider(
                value: Binding(
                    get: {
                        guard editor.items.indices.contains(selected.index) else {
                            return 1
                        }
                        return editor.items[selected.index].color?.alpha ?? 1
                    },
                    set: { opacity in
                        guard editor.items.indices.contains(selected.index),
                              let color = editor.items[selected.index].color else {
                            return
                        }
                        
                        switch editor.items[selected.index] {
                        case .circle(let shapePoint):
                            let shape = CirclePoint(
                                id: shapePoint.id,
                                rect: shapePoint.rect,
                                color: color.replacingAlpha(with: opacity)
                            )
                            editor.items[selected.index] = .circle(shape)
                            
                        case .rectangle(let shapePoint):
                            let shape = RectanglePoint(
                                id: shapePoint.id,
                                rect: shapePoint.rect,
                                color: color.replacingAlpha(with: opacity),
                                cornerRadius: shapePoint.cornerRadius,
                            )
                            editor.items[selected.index] = .rectangle(shape)
                            
                        case .triangle(let shapePoint):
                            let shape = TrianglePoint(
                                id: shapePoint.id,
                                rect: shapePoint.rect,
                                color: color.replacingAlpha(with: opacity)
                            )
                            editor.items[selected.index] = .triangle(shape)
                        case .pen(let penStroke):
                            let stroke = PenStroke(
                                id: penStroke.id,
                                points: penStroke.points,
                                color: penStroke.color.replacingAlpha(with: opacity),
                                lineWidth: penStroke.lineWidth
                            )
                            editor.items[selected.index] = .pen(stroke)
                            
                        default:
                            break
                        }
                    }
                ),
                in: 0...1,
                step: 0.1
            )
            .labelsHidden()
            .controlSize(.small)
            .frame(width: 120)
        }

    }
}
