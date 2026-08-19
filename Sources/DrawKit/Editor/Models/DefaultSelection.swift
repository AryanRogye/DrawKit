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
    public var arrowSelection = ArrowDefaultSelection()

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
              (1...DefaultSelectionStorage.currentVersion).contains(storage.version) else {
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

        arrowSelection.cornerRadius = CGFloat(storage.arrow.cornerRadius ?? 0)
        arrowSelection.strokeWidth = storage.arrow.strokeWidth.map { CGFloat($0) }
        arrowSelection.strokeColor = storage.arrow.strokeColor?.color
        arrowSelection.overrideColor = storage.arrow.overrideColor?.color
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
    static let currentVersion = 2

    let version: Int
    let rectangle: ShapeStorage
    let circle: ShapeStorage
    let triangle: ShapeStorage
    let arrow: ShapeStorage

    private enum CodingKeys: String, CodingKey {
        case version
        case rectangle
        case circle
        case triangle
        case arrow
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
        rectangle = try container.decodeIfPresent(ShapeStorage.self, forKey: .rectangle) ?? .init()
        circle = try container.decodeIfPresent(ShapeStorage.self, forKey: .circle) ?? .init()
        triangle = try container.decodeIfPresent(ShapeStorage.self, forKey: .triangle) ?? .init()
        arrow = try container.decodeIfPresent(ShapeStorage.self, forKey: .arrow) ?? .init()
    }

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
              let arrow = ShapeStorage(
                cornerRadius: Double(selection.arrowSelection.cornerRadius),
                strokeWidth: selection.arrowSelection.strokeWidth.map { Double($0) },
                strokeColor: selection.arrowSelection.strokeColor,
                overrideColor: selection.arrowSelection.overrideColor
              ),
              let triangle = ShapeStorage(
                cornerRadius: Double(selection.triangleSelection.cornerRadius),
                strokeWidth: selection.triangleSelection.strokeWidth.map { Double($0) },
                strokeColor: selection.triangleSelection.strokeColor,
                overrideColor: selection.triangleSelection.overrideColor
              )
        else {
            return nil
        }

        self.version = Self.currentVersion
        self.rectangle = rectangle
        self.circle = circle
        self.triangle = triangle
        self.arrow = arrow
    }
}

private struct ShapeStorage: Codable {
    let cornerRadius: Double?
    let strokeWidth: Double?
    let strokeColor: ColorStorage?
    let overrideColor: ColorStorage?

    init() {
        cornerRadius = nil
        strokeWidth = nil
        strokeColor = nil
        overrideColor = nil
    }

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

    func setStrokeEnabled(_ isEnabled: Bool) {
        strokeWidth = isEnabled ? 1 : nil
        if isEnabled && strokeColor == nil {
            strokeColor = .black
        }
    }
    
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

// MARK: - Rectangle Corner Radius

public struct RectangleDefaultSelectionCornerRadiusView: View {
    @Bindable var rectangleDefaultSelection: RectangleDefaultSelection
    
    public init(
        rectangleDefaultSelection: RectangleDefaultSelection
    ) {
        self.rectangleDefaultSelection = rectangleDefaultSelection
    }
    
    public var body: some View {
        HStack {
            Text(
                "Corner Radius: \(rectangleDefaultSelection.cornerRadius, format: .number.precision(.fractionLength(0...1)))"
            )
            Slider(
                value: $rectangleDefaultSelection.cornerRadius,
                in: 0...50
            )
        }
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
                    rectangleDefaultSelection.setStrokeEnabled(isEnabled)
                }
            )
        )
        
        if let strokeWidth = rectangleDefaultSelection.strokeWidth {
            HStack {
                Text(
                    "Stroke Width: \(strokeWidth, format: .number.precision(.fractionLength(0...1)))"
                )
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
            
            HStack {
                Text(
                    "Opacity: \(rectangleDefaultSelection.overrideColor?.alpha ?? 1, format: .percent.precision(.fractionLength(0)))"
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
}

// MARK: - Circle Default Selection
@Observable
@MainActor
public class CircleDefaultSelection {
    
    public var strokeWidth : CGFloat?
    public var strokeColor : Color?
    public var overrideColor: Color?

    func setStrokeEnabled(_ isEnabled: Bool) {
        strokeWidth = isEnabled ? 1 : nil
        if isEnabled && strokeColor == nil {
            strokeColor = .black
        }
    }
    
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
                    circleDefaultSelection.setStrokeEnabled(isEnabled)
                }
            )
        )
        
        if let strokeWidth = circleDefaultSelection.strokeWidth {
            HStack {
                Text(
                    "Stroke Width: \(strokeWidth, format: .number.precision(.fractionLength(0...1)))"
                )
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
            
            HStack {
                Text(
                    "Opacity: \(circleDefaultSelection.overrideColor?.alpha ?? 1, format: .percent.precision(.fractionLength(0)))"
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
}

// MARK: - Triangle Default Selection
@Observable
@MainActor
public class TriangleDefaultSelection {
    
    public var cornerRadius: CGFloat = 0
    public var strokeWidth : CGFloat?
    public var strokeColor : Color?
    public var overrideColor: Color?

    func setStrokeEnabled(_ isEnabled: Bool) {
        strokeWidth = isEnabled ? 1 : nil
        if isEnabled && strokeColor == nil {
            strokeColor = .black
        }
    }
    
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
        HStack {
            Text(
                "Corner Radius: \(triangleDefaultSelection.cornerRadius, format: .number.precision(.fractionLength(0...1)))"
            )
            Slider(
                value: $triangleDefaultSelection.cornerRadius,
                in: 0...50
            )
        }
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
                    triangleDefaultSelection.setStrokeEnabled(isEnabled)
                }
            )
        )
        
        if let strokeWidth = triangleDefaultSelection.strokeWidth {
            HStack {
                Text(
                    "Stroke Width: \(strokeWidth, format: .number.precision(.fractionLength(0...1)))"
                )
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
            
            HStack {
                Text(
                    "Opacity: \(triangleDefaultSelection.overrideColor?.alpha ?? 1, format: .percent.precision(.fractionLength(0)))"
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
}

// MARK: - Arrow Default Selection

@Observable
@MainActor
public final class ArrowDefaultSelection {
    public var cornerRadius: CGFloat = 0
    public var strokeWidth : CGFloat?
    public var strokeColor : Color?
    public var overrideColor: Color?

    var isStrokeEnabled: Bool {
        get { strokeWidth != nil }
        set { setStrokeEnabled(newValue) }
    }

    var editableStrokeWidth: CGFloat {
        get { strokeWidth ?? 1 }
        set { strokeWidth = newValue }
    }

    var isStrokeColorOverridden: Bool {
        get { strokeColor != nil }
        set { strokeColor = newValue ? (strokeColor ?? .black) : nil }
    }

    var editableStrokeColor: Color {
        get { strokeColor ?? .black }
        set { strokeColor = newValue }
    }

    var isColorOverridden: Bool {
        get { overrideColor != nil }
        set { overrideColor = newValue ? (overrideColor ?? .black) : nil }
    }

    var editableColor: Color {
        get { overrideColor ?? .black }
        set { overrideColor = newValue }
    }

    var overrideOpacity: Double {
        get { overrideColor?.alpha ?? 1 }
        set { overrideColor = (overrideColor ?? .black).replacingAlpha(with: newValue) }
    }

    func setStrokeEnabled(_ isEnabled: Bool) {
        strokeWidth = isEnabled ? 1 : nil
        if isEnabled && strokeColor == nil {
            strokeColor = .black
        }
    }

    func create(at center: CGRect, color: Color) -> ArrowPoint {
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

// MARK: - Arrow Corner Radius

public struct ArrowDefaultSelectionCornerRadiusView: View {
    @Bindable var arrowDefaultSelection: ArrowDefaultSelection

    public init(
        arrowDefaultSelection: ArrowDefaultSelection
    ) {
        self.arrowDefaultSelection = arrowDefaultSelection
    }

    public var body: some View {
        HStack {
            Text(
                "Corner Radius: \(arrowDefaultSelection.cornerRadius, format: .number.precision(.fractionLength(0...1)))",
                comment: "Arrow default corner-radius control showing the current value."
            )
            Slider(
                value: $arrowDefaultSelection.cornerRadius,
                in: 0...50
            )
        }
    }
}

// MARK: - Arrow Stroke Width

public struct ArrowDefaultSelectionStrokeWidthView: View {
    @Bindable var arrowDefaultSelection: ArrowDefaultSelection

    public init(
        arrowDefaultSelection: ArrowDefaultSelection
    ) {
        self.arrowDefaultSelection = arrowDefaultSelection
    }

    public var body: some View {
        Toggle(isOn: $arrowDefaultSelection.isStrokeEnabled) {
            Text(
                "Stroke",
                comment: "Toggle that enables the default arrow stroke."
            )
        }

        if arrowDefaultSelection.isStrokeEnabled {
            HStack {
                Text(
                    "Stroke Width: \(arrowDefaultSelection.editableStrokeWidth, format: .number.precision(.fractionLength(0...1)))",
                    comment: "Arrow default stroke-width control showing the current value."
                )
                Slider(
                    value: $arrowDefaultSelection.editableStrokeWidth,
                    in: 1...20
                )
            }
        }
    }
}

// MARK: - Arrow Stroke Color

public struct ArrowDefaultSelectionStrokeColorView: View {
    @Bindable var arrowDefaultSelection: ArrowDefaultSelection

    public init(
        arrowDefaultSelection: ArrowDefaultSelection
    ) {
        self.arrowDefaultSelection = arrowDefaultSelection
    }

    public var body: some View {
        Toggle(isOn: $arrowDefaultSelection.isStrokeColorOverridden) {
            Text(
                "Override Stroke Color",
                comment: "Toggle that enables a custom default arrow stroke color."
            )
        }

        if arrowDefaultSelection.isStrokeColorOverridden {
            ColorPicker(selection: $arrowDefaultSelection.editableStrokeColor) {
                Text(
                    "Stroke Color",
                    comment: "Picker for the default arrow stroke color."
                )
            }
        }
    }
}

// MARK: - Arrow Override Color

public struct ArrowDefaultSelectionOverrideColorView: View {
    @Bindable var arrowDefaultSelection: ArrowDefaultSelection

    public init(
        arrowDefaultSelection: ArrowDefaultSelection
    ) {
        self.arrowDefaultSelection = arrowDefaultSelection
    }

    public var body: some View {
        Toggle(isOn: $arrowDefaultSelection.isColorOverridden) {
            Text(
                "Override Color",
                comment: "Toggle that enables a custom default arrow fill color."
            )
        }

        if arrowDefaultSelection.isColorOverridden {
            ColorPicker(selection: $arrowDefaultSelection.editableColor) {
                Text(
                    "Color",
                    comment: "Picker for the default arrow fill color."
                )
            }

            HStack {
                Text(
                    "Opacity: \(arrowDefaultSelection.overrideOpacity, format: .percent.precision(.fractionLength(0)))",
                    comment: "Arrow default fill-opacity control showing the current percentage."
                )
                Slider(
                    value: $arrowDefaultSelection.overrideOpacity,
                    in: 0...1
                )
            }
        }
    }
}
