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
                    editor.deleteSelectedItem()
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
                            editor.setStrokeColor($0, at: index)
                        }
                    )
                )
                
                Slider(
                    value: Binding(
                        get: {
                            editor.items[index].strokeWidth ?? strokeWidth
                        },
                        set: {
                            editor.setStrokeWidth($0, at: index)
                        }
                    ),
                    in: 0...10,
                    step: 1,
                    onEditingChanged: historyEditingChanged
                )
                
                Button("Disable Stroke") {
                    editor.setStroke(width: nil, color: nil, at: index)
                }
                
            } else {
                Button("Enable Stroke") {
                    editor.setStroke(width: 1, color: .blue, at: index)
                }
            }
        }
    }

    private func historyEditingChanged(_ isEditing: Bool) {
        if isEditing {
            editor.beginHistoryTransaction()
        } else {
            editor.commitHistoryTransaction()
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
                            editor.setCornerRadius($0, at: selected.index)
                        }
                    ),
                    in: 0...(min(width, height) / 2),
                    step: 1,
                    onEditingChanged: historyEditingChanged
                )
                .labelsHidden()
                .controlSize(.small)
                .frame(width: 120)
            }
        }
    }

    private func historyEditingChanged(_ isEditing: Bool) {
        if isEditing {
            editor.beginHistoryTransaction()
        } else {
            editor.commitHistoryTransaction()
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
                            editor.setOpacity($0, at: index)
                        }
                    ),
                    in: 0...1,
                    step: 0.1,
                    onEditingChanged: historyEditingChanged
                )
                .labelsHidden()
                .controlSize(.small)
                .frame(width: 120)
            }
            
        }
    }

    private func historyEditingChanged(_ isEditing: Bool) {
        if isEditing {
            editor.beginHistoryTransaction()
        } else {
            editor.commitHistoryTransaction()
        }
    }
}
