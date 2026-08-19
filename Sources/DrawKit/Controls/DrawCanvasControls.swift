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
        case eraser
        case shapes
        case arrow
    }
    
    public var body: some View {
        ZStack {
            if editor.selectedItem.kind == .pen || editor.selectedItem.kind == .eraser {
                HStack {
                    Button {
                        editor.selectedItem = .none
                        editor.canvasSelected = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                            .background {
                                Circle()
                                    .fill(.primary.opacity(0.08))
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.leading)
                    
                    Rectangle()
                        .fill(.primary.opacity(0.1))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                    
                    ThicknessControl(value: Binding(
                        get: { editor.lineWidth },
                        set: { editor.changePenLineWidth(to: $0) }
                    ))
                    .frame(width: 200)
                    .padding(.trailing)
                }
                .frame(height: 44)
                .background {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    .primary.opacity(0.2),
                                    style: .init(lineWidth: 1)
                                )
                        }
                        .shadow(radius: 5)
                }
                .offset(y: -60)
                .transition(.move(edge: .bottom))
            }
            
            HStack(spacing: 32) {
                ForEach(MarkupKind.allCases, id: \.self) { tool in
                    switch tool {
                    case .pen:
                        Button(action: {
                            editor.select(.pen, with: selectedColor)
                        }) {
                            PenShape()
                                .frame(
                                    width: 35,
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
                    case .eraser:
                        Button(action: {
                            editor.select(.eraser, with: selectedColor)
                        }) {
                            EraserShape()
                                .frame(width: 40)
                                .shadow(
                                    color: .black.opacity(0.2),
                                    radius: 5
                                )
                                .overlay {
                                    if editor.selectedItem.kind == .eraser {
                                        EraserShape()
                                            .colorMultiply(.accentColor)
                                            .opacity(0.25)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .offset(y: 10)
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
                    case .arrow:
                        Button(action: {
                            editor.select(.arrow, with: selectedColor)
                        }) {
                            CursorShape()
                                .frame(width: 40)
                                .scaleEffect(1.65)
                                .overlay {
                                    if editor.selectedItem.kind == .arrow {
                                        CursorShape(color: .accentColor.opacity(0.2))
                                            .scaleEffect(1.65)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .rotationEffect(.degrees(-43))
                        .offset(x: -12, y: -7)
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
                .padding(.vertical, 8)
                .padding(.leading, -24)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .background {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                .primary.opacity(0.2),
                                style: .init(lineWidth: 1)
                            )
                    }
                    .shadow(radius: 5)
            }
            .padding(.bottom, 8)
        }
        .animation(.spring, value: editor.selectedItem.kind)
        .onChange(of: editor.canvasSelected) { _, newValue in
            if let newValue {
                if let color = editor.items[newValue.index].color {
                    self.selectedColor = color
                }
            }
        }
        .onChange(of: selectedColor) { _, newValue in
            editor.changeSelectedColorIfNeeded(newValue)
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
                    if selected.equals(color, ignoreAlpha: true) {
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
