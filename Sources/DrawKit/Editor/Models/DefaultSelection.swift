//
//  DefaultSelection.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/18/26.
//

import Foundation
import SwiftUI

/// Defines the default configuration applied when creating new markup items.
///
/// This allows an app embedding DrawKit to customize how newly created shapes
/// should appear. For example, an app may want rectangles to always use a
/// specific stroke width, corner radius, stroke color, or fill color.

@Observable
@MainActor
public class DefaultSelection {
    public var rectSelection = RectangleDefaultSelection()
    public var circleSelection = CircleDefaultSelection()
    public var triangleSelection = TriangleDefaultSelection()
    
    public init() {

    }

    /// This init is created for the `Defaults` Framework
    /// This allows us to do:
    /// ```swift
    /// public struct DefaultSelectionBridge: Defaults.Bridge {
    ///     public typealias Value = DefaultSelection
    ///     public typealias Serializable = String
    ///
    ///     public func serialize(_ value: DrawKit.DefaultSelection?) -> String? {
    ///         return value?.asString()
    ///     }
    ///
    ///     public func deserialize(_ object: String?) -> DrawKit.DefaultSelection? {
    ///         return DefaultSelection(fromString: object)
    ///     }
    /// }
    ///
    /// extension DefaultSelection: Defaults.Serializable {
    ///     public static let bridge = DefaultSelectionBridge()
    /// }
    ///
    /// extension Defaults.Keys {
    ///     static let editorDefaultSelection = Key<DefaultSelection>("editor_default_selection", default: .init())
    /// }
    /// ```
    public init(fromString: String?) {
        guard let fromString,
              let data = fromString.data(using: .utf8),
              let storage = try? JSONDecoder().decode(
                DefaultSelectionStorage.self,
                from: data
              ),
              storage.version == DefaultSelectionStorage.currentVersion else {
            return
        }

        rectSelection.cornerRadius = CGFloat(storage.rectangle.cornerRadius ?? 0)
        rectSelection.strokeWidth = storage.rectangle.strokeWidth.map { CGFloat($0) }
        rectSelection.strokeColor = storage.rectangle.strokeColor?.color
        rectSelection.overrideColor = storage.rectangle.overrideColor?.color

        circleSelection.strokeWidth = storage.circle.strokeWidth.map { CGFloat($0) }
        circleSelection.strokeColor = storage.circle.strokeColor?.color
        circleSelection.overrideColor = storage.circle.overrideColor?.color

        triangleSelection.cornerRadius = CGFloat(storage.triangle.cornerRadius ?? 0)
        triangleSelection.strokeWidth = storage.triangle.strokeWidth.map { CGFloat($0) }
        triangleSelection.strokeColor = storage.triangle.strokeColor?.color
        triangleSelection.overrideColor = storage.triangle.overrideColor?.color
    }

    public func asString() -> String? {
        guard let storage = DefaultSelectionStorage(selection: self),
              let data = try? JSONEncoder.defaultSelectionEncoder.encode(storage) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

private struct DefaultSelectionStorage: Codable {
    static let currentVersion = 1

    let version: Int
    let rectangle: ShapeStorage
    let circle: ShapeStorage
    let triangle: ShapeStorage

    @MainActor
    init?(selection: DefaultSelection) {
        guard let rectangle = ShapeStorage(
            cornerRadius: Double(selection.rectSelection.cornerRadius),
            strokeWidth: selection.rectSelection.strokeWidth.map { Double($0) },
            strokeColor: selection.rectSelection.strokeColor,
            overrideColor: selection.rectSelection.overrideColor
        ),
        let circle = ShapeStorage(
            cornerRadius: nil,
            strokeWidth: selection.circleSelection.strokeWidth.map { Double($0) },
            strokeColor: selection.circleSelection.strokeColor,
            overrideColor: selection.circleSelection.overrideColor
        ),
        let triangle = ShapeStorage(
            cornerRadius: Double(selection.triangleSelection.cornerRadius),
            strokeWidth: selection.triangleSelection.strokeWidth.map { Double($0) },
            strokeColor: selection.triangleSelection.strokeColor,
            overrideColor: selection.triangleSelection.overrideColor
        ) else {
            return nil
        }

        self.version = Self.currentVersion
        self.rectangle = rectangle
        self.circle = circle
        self.triangle = triangle
    }
}

private struct ShapeStorage: Codable {
    let cornerRadius: Double?
    let strokeWidth: Double?
    let strokeColor: ColorStorage?
    let overrideColor: ColorStorage?

    init?(
        cornerRadius: Double?,
        strokeWidth: Double?,
        strokeColor: Color?,
        overrideColor: Color?
    ) {
        let storedStrokeColor: ColorStorage?
        if let strokeColor {
            guard let color = ColorStorage(strokeColor) else { return nil }
            storedStrokeColor = color
        } else {
            storedStrokeColor = nil
        }

        let storedOverrideColor: ColorStorage?
        if let overrideColor {
            guard let color = ColorStorage(overrideColor) else { return nil }
            storedOverrideColor = color
        } else {
            storedOverrideColor = nil
        }

        self.cornerRadius = cornerRadius
        self.strokeWidth = strokeWidth
        self.strokeColor = storedStrokeColor
        self.overrideColor = storedOverrideColor
    }
}

private struct ColorStorage: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init?(_ color: Color) {
        guard let rgba = color.rgba else { return nil }
        self.red = Double(rgba.r)
        self.green = Double(rgba.g)
        self.blue = Double(rgba.b)
        self.alpha = Double(rgba.a)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

private extension JSONEncoder {
    static var defaultSelectionEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}

// MARK: - Rectangle Default Selection
@Observable
@MainActor
public class RectangleDefaultSelection {
    
    public var cornerRadius: CGFloat = 0
    public var strokeWidth : CGFloat?
    public var strokeColor : Color?
    public var overrideColor: Color?
    
    func create(at center: CGRect, color: Color) -> RectanglePoint {
        return .init(
            rect: center,
            color: (overrideColor != nil ? overrideColor! : color),
            cornerRadius: cornerRadius,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            rotation: .degrees(0)
        )
    }
}

public struct RectangleDefaultSelectionCornerRadiusView: View {
    @Bindable var rectangleDefaultSelection: RectangleDefaultSelection
    
    public init(
        rectangleDefaultSelection: RectangleDefaultSelection
    ) {
        self.rectangleDefaultSelection = rectangleDefaultSelection
    }
    
    public var body: some View {
        Slider(
            value: $rectangleDefaultSelection.cornerRadius,
            in: 0...50
        )
    }
}


// MARK: - Rectangle Stroke Width

public struct RectangleDefaultSelectionStrokeWidthView: View {
    @Bindable var rectangleDefaultSelection: RectangleDefaultSelection
    
    public init(
        rectangleDefaultSelection: RectangleDefaultSelection
    ) {
        self.rectangleDefaultSelection = rectangleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Stroke",
            isOn: Binding(
                get: {
                    rectangleDefaultSelection.strokeWidth != nil
                },
                set: { isEnabled in
                    rectangleDefaultSelection.strokeWidth = isEnabled ? 1 : nil
                }
            )
        )
        
        if rectangleDefaultSelection.strokeWidth != nil {
            Slider(
                value: Binding(
                    get: {
                        rectangleDefaultSelection.strokeWidth ?? 1
                    },
                    set: {
                        rectangleDefaultSelection.strokeWidth = $0
                    }
                ),
                in: 1...20
            )
        }
    }
}


// MARK: - Rectangle Stroke Color

public struct RectangleDefaultSelectionStrokeColorView: View {
    @Bindable var rectangleDefaultSelection: RectangleDefaultSelection
    
    public init(
        rectangleDefaultSelection: RectangleDefaultSelection
    ) {
        self.rectangleDefaultSelection = rectangleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Override Stroke Color",
            isOn: Binding(
                get: {
                    rectangleDefaultSelection.strokeColor != nil
                },
                set: { isEnabled in
                    rectangleDefaultSelection.strokeColor = isEnabled ? .black : nil
                }
            )
        )
        
        if rectangleDefaultSelection.strokeColor != nil {
            ColorPicker(
                "Stroke Color",
                selection: Binding(
                    get: {
                        rectangleDefaultSelection.strokeColor ?? .black
                    },
                    set: {
                        rectangleDefaultSelection.strokeColor = $0
                    }
                )
            )
        }
    }
}


// MARK: - Rectangle Override Color

public struct RectangleDefaultSelectionOverrideColorView: View {
    @Bindable var rectangleDefaultSelection: RectangleDefaultSelection
    
    public init(
        rectangleDefaultSelection: RectangleDefaultSelection
    ) {
        self.rectangleDefaultSelection = rectangleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Override Color",
            isOn: Binding(
                get: {
                    rectangleDefaultSelection.overrideColor != nil
                },
                set: { isEnabled in
                    rectangleDefaultSelection.overrideColor = isEnabled ? .black : nil
                }
            )
        )
        
        if rectangleDefaultSelection.overrideColor != nil {
            ColorPicker(
                "Color",
                selection: Binding(
                    get: {
                        rectangleDefaultSelection.overrideColor ?? .black
                    },
                    set: {
                        rectangleDefaultSelection.overrideColor = $0
                    }
                )
            )
            
            Slider(
                value: Binding(
                    get: {
                        rectangleDefaultSelection.overrideColor?.alpha ?? 1
                    },
                    set: { opacity in
                        rectangleDefaultSelection.overrideColor =
                        rectangleDefaultSelection.overrideColor?
                            .replacingAlpha(with: opacity)
                    }
                ),
                in: 0...1
            )
        }
    }
}

// MARK: - Circle Default Selection
@Observable
@MainActor
public class CircleDefaultSelection {
    
    public var strokeWidth : CGFloat?
    public var strokeColor : Color?
    public var overrideColor: Color?
    
    func create(at center: CGRect, color: Color) -> CirclePoint {
        return .init(
            rect: center,
            color: (overrideColor != nil ? overrideColor! : color),
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            rotation: .degrees(0)
        )
    }
}

// MARK: - Circle Stroke Width

public struct CircleDefaultSelectionStrokeWidthView: View {
    @Bindable var circleDefaultSelection: CircleDefaultSelection
    
    public init(
        circleDefaultSelection: CircleDefaultSelection
    ) {
        self.circleDefaultSelection = circleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Stroke",
            isOn: Binding(
                get: {
                    circleDefaultSelection.strokeWidth != nil
                },
                set: { isEnabled in
                    circleDefaultSelection.strokeWidth = isEnabled ? 1 : nil
                }
            )
        )
        
        if circleDefaultSelection.strokeWidth != nil {
            Slider(
                value: Binding(
                    get: {
                        circleDefaultSelection.strokeWidth ?? 1
                    },
                    set: {
                        circleDefaultSelection.strokeWidth = $0
                    }
                ),
                in: 1...20
            )
        }
    }
}


// MARK: - Circle Stroke Color

public struct CircleDefaultSelectionStrokeColorView: View {
    @Bindable var circleDefaultSelection: CircleDefaultSelection
    
    public init(
        circleDefaultSelection: CircleDefaultSelection
    ) {
        self.circleDefaultSelection = circleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Override Stroke Color",
            isOn: Binding(
                get: {
                    circleDefaultSelection.strokeColor != nil
                },
                set: { isEnabled in
                    circleDefaultSelection.strokeColor = isEnabled ? .black : nil
                }
            )
        )
        
        if circleDefaultSelection.strokeColor != nil {
            ColorPicker(
                "Stroke Color",
                selection: Binding(
                    get: {
                        circleDefaultSelection.strokeColor ?? .black
                    },
                    set: {
                        circleDefaultSelection.strokeColor = $0
                    }
                )
            )
        }
    }
}


// MARK: - Circle Override Color

public struct CircleDefaultSelectionOverrideColorView: View {
    @Bindable var circleDefaultSelection: CircleDefaultSelection
    
    public init(
        circleDefaultSelection: CircleDefaultSelection
    ) {
        self.circleDefaultSelection = circleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Override Color",
            isOn: Binding(
                get: {
                    circleDefaultSelection.overrideColor != nil
                },
                set: { isEnabled in
                    circleDefaultSelection.overrideColor = isEnabled ? .black : nil
                }
            )
        )
        
        if circleDefaultSelection.overrideColor != nil {
            ColorPicker(
                "Color",
                selection: Binding(
                    get: {
                        circleDefaultSelection.overrideColor ?? .black
                    },
                    set: {
                        circleDefaultSelection.overrideColor = $0
                    }
                )
            )
            
            Slider(
                value: Binding(
                    get: {
                        circleDefaultSelection.overrideColor?.alpha ?? 1
                    },
                    set: { opacity in
                        circleDefaultSelection.overrideColor =
                        circleDefaultSelection.overrideColor?
                            .replacingAlpha(with: opacity)
                    }
                ),
                in: 0...1
            )
        }
    }
}

// MARK: - Triangle Default Selection
@Observable
@MainActor
public class TriangleDefaultSelection {
    
    public var cornerRadius: CGFloat = 0
    public var strokeWidth : CGFloat?
    public var strokeColor : Color?
    public var overrideColor: Color?
    
    func create(at center: CGRect, color: Color) -> TrianglePoint {
        .init(
            rect: center,
            color: (overrideColor != nil ? overrideColor! : color),
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            cornerRadius: cornerRadius,
            rotation: .degrees(0)
        )
    }
}

public struct TriangleDefaultSelectionCornerRadiusView: View {
    @Bindable var triangleDefaultSelection: TriangleDefaultSelection
    
    public init(
        triangleDefaultSelection: TriangleDefaultSelection
    ) {
        self.triangleDefaultSelection = triangleDefaultSelection
    }
    
    public var body: some View {
        Slider(
            value: $triangleDefaultSelection.cornerRadius,
            in: 0...50
        )
    }
}


// MARK: - Triangle Stroke Width

public struct TriangleDefaultSelectionStrokeWidthView: View {
    @Bindable var triangleDefaultSelection: TriangleDefaultSelection
    
    public init(
        triangleDefaultSelection: TriangleDefaultSelection
    ) {
        self.triangleDefaultSelection = triangleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Stroke",
            isOn: Binding(
                get: {
                    triangleDefaultSelection.strokeWidth != nil
                },
                set: { isEnabled in
                    triangleDefaultSelection.strokeWidth = isEnabled ? 1 : nil
                }
            )
        )
        
        if triangleDefaultSelection.strokeWidth != nil {
            Slider(
                value: Binding(
                    get: {
                        triangleDefaultSelection.strokeWidth ?? 1
                    },
                    set: {
                        triangleDefaultSelection.strokeWidth = $0
                    }
                ),
                in: 1...20
            )
        }
    }
}


// MARK: - Triangle Stroke Color

public struct TriangleDefaultSelectionStrokeColorView: View {
    @Bindable var triangleDefaultSelection: TriangleDefaultSelection
    
    public init(
        triangleDefaultSelection: TriangleDefaultSelection
    ) {
        self.triangleDefaultSelection = triangleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Override Stroke Color",
            isOn: Binding(
                get: {
                    triangleDefaultSelection.strokeColor != nil
                },
                set: { isEnabled in
                    triangleDefaultSelection.strokeColor = isEnabled ? .black : nil
                }
            )
        )
        
        if triangleDefaultSelection.strokeColor != nil {
            ColorPicker(
                "Stroke Color",
                selection: Binding(
                    get: {
                        triangleDefaultSelection.strokeColor ?? .black
                    },
                    set: {
                        triangleDefaultSelection.strokeColor = $0
                    }
                )
            )
        }
    }
}


// MARK: - Triangle Override Color

public struct TriangleDefaultSelectionOverrideColorView: View {
    @Bindable var triangleDefaultSelection: TriangleDefaultSelection
    
    public init(
        triangleDefaultSelection: TriangleDefaultSelection
    ) {
        self.triangleDefaultSelection = triangleDefaultSelection
    }
    
    public var body: some View {
        Toggle(
            "Override Color",
            isOn: Binding(
                get: {
                    triangleDefaultSelection.overrideColor != nil
                },
                set: { isEnabled in
                    triangleDefaultSelection.overrideColor = isEnabled ? .black : nil
                }
            )
        )
        
        if triangleDefaultSelection.overrideColor != nil {
            ColorPicker(
                "Color",
                selection: Binding(
                    get: {
                        triangleDefaultSelection.overrideColor ?? .black
                    },
                    set: {
                        triangleDefaultSelection.overrideColor = $0
                    }
                )
            )
            
            Slider(
                value: Binding(
                    get: {
                        triangleDefaultSelection.overrideColor?.alpha ?? 1
                    },
                    set: { opacity in
                        triangleDefaultSelection.overrideColor =
                        triangleDefaultSelection.overrideColor?
                            .replacingAlpha(with: opacity)
                    }
                ),
                in: 0...1
            )
        }
    }
}
