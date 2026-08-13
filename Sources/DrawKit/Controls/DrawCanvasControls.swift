//
//  DrawCanvasControls.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

public struct DrawCanvasControls: View {
    
    @Bindable var editor: DrawEditor
    @State private var selectedColor: Color = .black
    
    public init(editor: DrawEditor) {
        self.editor = editor
    }
    
    // while drawing this is split up like this
    private enum MarkupKind: String, CaseIterable {
        case pen
        case shapes
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(.white)
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        .primary.opacity(0.2),
                        style: .init(lineWidth: 1)
                    )
            }
            .overlay {
                HStack(spacing: 32) {
                    ForEach(MarkupKind.allCases, id: \.self) { tool in
                        switch tool {
                        case .pen:
                            Button(action: {
                                editor.select(.pen, with: selectedColor)
                            }) {
                                PenShape()
                                    .frame(
                                        width: 40,
                                    )
                                    .shadow(
                                        color: .black.opacity(0.2),
                                        radius: 5
                                    )
                                    .overlay {
                                        if editor.selectedItem.kind == .pen {
                                            PenShapeStroke(color: .accentColor.opacity(0.2))
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        case .shapes:
                            ZStack {
                                Button(action: {
                                    editor.select(.rectangle, with: selectedColor)
                                }) {
                                    CanvasControlsShape(
                                        shape: RoundedRectangle(cornerRadius: 12),
                                        selected: editor.selectedItem.kind == .rectangle
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                
                                Button(action: {
                                    editor.select(.circle, with: selectedColor)
                                }) {
                                    CanvasControlsShape(
                                        shape: Circle(),
                                        selected: editor.selectedItem.kind == .circle
                                    )
                                }
                                .buttonStyle(.plain)
                                .offset(x: -20, y: 25)

                                Button(action: {
                                    editor.select(.triangle, with: selectedColor)
                                }) {
                                    CanvasControlsShape(
                                        shape: TriangleShape(),
                                        selected: editor.selectedItem.kind == .triangle
                                    )
                                }
                                .buttonStyle(.plain)
                                .offset(x: 20, y: 15)

                            }
                        }
                    }
                    
                    // Color Picker Here
                    VStack {
                        HStack {
                            ColorCircle(Color(.systemRed), selected: $selectedColor)
                            ColorCircle(Color(.systemOrange), selected: $selectedColor)
                            ColorCircle(Color(.systemYellow), selected: $selectedColor)
                            ColorCircle(Color(.systemGreen), selected: $selectedColor)
                            ColorCircle(Color(.black), selected: $selectedColor)
                        }
                        HStack {
                            ColorCircle(Color(.systemCyan), selected: $selectedColor)
                            ColorCircle(Color(.systemPurple), selected: $selectedColor)
                            ColorCircle(Color(.systemPink), selected: $selectedColor)
                            ColorCircle(Color(.systemGray), selected: $selectedColor)
                            ColorCircle(Color(.systemTeal), selected: $selectedColor)
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 80)
            .padding()
            .onChange(of: selectedColor) { _, newValue in
                editor.changeSelectedColorIfNeeded(newValue)
            }
            .onChange(of: editor.canvasSelected) { _, newValue in
                if let newValue {
                    if let color = editor.items[newValue.index].color {
                        self.selectedColor = color
                    }
                }
            }
    }
}

private struct ColorCircle: View {
    
    let color: Color
    @Binding var selected: Color
    
    init(_ color: Color, selected: Binding<Color>) {
        self.color = color
        self._selected = selected
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring) {
                selected = color
            }
        }) {
            Circle()
                .fill(color)
                .padding(2)
                .overlay {
                    if selected.equals(color) {
                        Circle()
                            .stroke(.blue)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

private struct CanvasControlsShape<Selection: Shape>: View {
    
    let shape: Selection
    let selected: Bool
    
    var body: some View {
        shape
            .fill(.yellow)
            .frame(
                width: 90,
            )
            .overlay {
                shape
                    .stroke(
                        .gray.mix(with: .white.opacity(0.5), by: 0.9)
                    )
            }
            .shadow(
                color: .black.opacity(0.2),
                radius: 5
            )
            .overlay {
                if selected {
                    shape
                        .fill(Color.accentColor.opacity(0.2))
                }
            }
    }
}

extension Color {
    
    private struct RGBA: Equatable {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
    }
    
    private var rgba: RGBA? {
        let nsColor = NSColor(self)
        
        guard let rgb = nsColor.usingColorSpace(.deviceRGB) else {
            return nil
        }
        
        let red = rgb.redComponent
        let green = rgb.greenComponent
        let blue = rgb.blueComponent
        let alpha = rgb.alphaComponent

        return RGBA(r: red, g: green, b: blue, a: alpha)
    }
    
    func equals(_ color: Color) -> Bool {
        
        guard let s_rgba = self.rgba, let c_rgba = color.rgba else { return false }
        
        return s_rgba == c_rgba
    }
}
