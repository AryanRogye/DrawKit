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
                    InspectorOpacitySlider(
                        editor: editor,
                        selected: selected
                    )
                    InspectorStrokeColorWidth(
                        editor: editor,
                        selected: selected
                    )
                    InspectorCornerRadiusSlider(
                        editor: editor,
                        selected: selected,
                    )
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

// MARK: - Stroke Width/Color
private struct InspectorStrokeColorWidth: View {
    
    @Bindable var editor: DrawEditor
    let selected: CanvasSelection
    
    var index: Int {
        selected.index
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if editor.items.indices.contains(index),
               let strokeColor = editor.items[index].strokeColor,
               let strokeWidth = editor.items[index].strokeWidth {
                
                ColorPicker(
                    "Stroke Color",
                    selection: Binding(
                        get: {
                            editor.items[index].strokeColor ?? strokeColor
                        },
                        set: {
                            editor.items[index].setStrokeColor($0)
                        }
                    )
                )
                
                Slider(
                    value: Binding(
                        get: {
                            editor.items[index].strokeWidth ?? strokeWidth
                        },
                        set: {
                            editor.items[index].setStrokeWidth($0)
                        }
                    ),
                    in: 0...10,
                    step: 1
                )
                
                Button("Disable Stroke") {
                    editor.items[index].setStrokeWidth(nil)
                    editor.items[index].setStrokeColor(nil)
                }
                
            } else {
                Button("Enable Stroke") {
                    editor.items[index].setStrokeWidth(1)
                    editor.items[index].setStrokeColor(.blue)
                }
            }
        }
    }
}

// MARK: - Corner Radius
private struct InspectorCornerRadiusSlider: View {
    
    @Bindable var editor: DrawEditor
    let selected: CanvasSelection
    
    var index: Int {
        selected.index
    }
    
    var body: some View {
        if editor.items.indices.contains(index),
           let cornerRadius = editor.items[index].cornerRadius,
           let width = editor.items[index].width,
           let height = editor.items[index].height
        {
            LabeledContent("Corner Radius") {
                Slider(
                    value: Binding(
                        get: {
                            cornerRadius
                        },
                        set: {
                            editor.items[selected.index].setCornerRadius($0)
                        }
                    ),
                    in: 0...(min(width, height) / 2),
                    step: 1
                )
                .labelsHidden()
                .controlSize(.small)
                .frame(width: 120)
            }
        }
    }
}

// MARK: - Opacity
private struct InspectorOpacitySlider: View {
    
    @Bindable var editor: DrawEditor
    let selected: CanvasSelection
    
    var index: Int {
        selected.index
    }
    
    var body: some View {
        if  editor.items.indices.contains(index),
            let color = editor.items[index].color {
            LabeledContent("Opacity") {
                Slider(
                    value: Binding(
                        get: {
                            return color.alpha
                        },
                        set: {
                            editor.items[index].setOpacity($0)
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
}
