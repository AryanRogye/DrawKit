import SwiftUI
import Testing
@testable import DrawKit

@MainActor
struct DefaultSelectionTests {
    @Test
    func rectangleSelectionAppliesEveryConfiguredDefault() throws {
        let defaults = DefaultSelection()
        let fill = Color(red: 0.2, green: 0.4, blue: 0.6, opacity: 0.35)
        let stroke = Color(red: 0.8, green: 0.1, blue: 0.3, opacity: 0.65)
        defaults.rectSelection.cornerRadius = 14
        defaults.rectSelection.strokeWidth = 6
        defaults.rectSelection.strokeColor = stroke
        defaults.rectSelection.overrideColor = fill
        let editor = makeEditor(defaultSelection: defaults)

        editor.select(.rectangle, with: .green)

        let rectangle = try rectangle(from: try #require(editor.items.first))
        #expect(rectangle.cornerRadius == 14)
        #expect(rectangle.strokeWidth == 6)
        #expect(colorsMatch(rectangle.strokeColor, stroke))
        #expect(colorsMatch(rectangle.color, fill))
        #expect(abs(rectangle.color.alpha - 0.35) < 0.001)
        #expect(rectangle.rotation == .zero)
        #expect(editor.selectedItem == editor.items.first)
    }

    @Test
    func circleSelectionAppliesEveryConfiguredDefault() throws {
        let defaults = DefaultSelection()
        let fill = Color(red: 0.1, green: 0.7, blue: 0.5, opacity: 0.45)
        let stroke = Color(red: 0.9, green: 0.8, blue: 0.2, opacity: 0.75)
        defaults.circleSelection.strokeWidth = 8
        defaults.circleSelection.strokeColor = stroke
        defaults.circleSelection.overrideColor = fill
        let editor = makeEditor(defaultSelection: defaults)

        editor.select(.circle, with: .purple)

        let circle = try circle(from: try #require(editor.items.first))
        #expect(circle.strokeWidth == 8)
        #expect(colorsMatch(circle.strokeColor, stroke))
        #expect(colorsMatch(circle.color, fill))
        #expect(abs(circle.color.alpha - 0.45) < 0.001)
        #expect(circle.rotation == .zero)
        #expect(editor.selectedItem == editor.items.first)
    }

    @Test
    func triangleSelectionAppliesEveryConfiguredDefault() throws {
        let defaults = DefaultSelection()
        let fill = Color(red: 0.6, green: 0.2, blue: 0.8, opacity: 0.55)
        let stroke = Color(red: 0.1, green: 0.3, blue: 0.9, opacity: 0.85)
        defaults.triangleSelection.cornerRadius = 11
        defaults.triangleSelection.strokeWidth = 5
        defaults.triangleSelection.strokeColor = stroke
        defaults.triangleSelection.overrideColor = fill
        let editor = makeEditor(defaultSelection: defaults)

        editor.select(.triangle, with: .orange)

        let triangle = try triangle(from: try #require(editor.items.first))
        #expect(triangle.cornerRadius == 11)
        #expect(triangle.strokeWidth == 5)
        #expect(colorsMatch(triangle.strokeColor, stroke))
        #expect(colorsMatch(triangle.color, fill))
        #expect(abs(triangle.color.alpha - 0.55) < 0.001)
        #expect(triangle.rotation == .zero)
        #expect(editor.selectedItem == editor.items.first)
    }

    @Test
    func selectionUsesRequestedColorWhenOverrideIsDisabled() throws {
        let requestedColor = Color(
            red: 0.25,
            green: 0.5,
            blue: 0.75,
            opacity: 0.4
        )
        let kinds: [MarkupRawKind] = [.rectangle, .circle, .triangle]

        for kind in kinds {
            let editor = makeEditor(defaultSelection: DefaultSelection())
            editor.select(kind, with: requestedColor)

            let item = try #require(editor.items.first)
            let appliedColor = try #require(item.color)
            #expect(colorsMatch(appliedColor, requestedColor))
            #expect(abs(appliedColor.alpha - 0.4) < 0.001)
            #expect(item.strokeWidth == nil)
            #expect(item.strokeColor == nil)
            if kind == .rectangle || kind == .triangle {
                #expect(item.cornerRadius == 0)
            }
        }
    }

    @Test
    func stringSerializationRoundTripsEveryDefault() throws {
        let original = DefaultSelection()
        original.rectSelection.cornerRadius = 14.25
        original.rectSelection.strokeWidth = 6.5
        original.rectSelection.strokeColor = Color(
            red: 0.8,
            green: 0.1,
            blue: 0.3,
            opacity: 0.65
        )
        original.rectSelection.overrideColor = Color(
            red: 0.2,
            green: 0.4,
            blue: 0.6,
            opacity: 0.35
        )
        original.circleSelection.strokeWidth = 8.75
        original.circleSelection.strokeColor = Color(
            red: 0.9,
            green: 0.8,
            blue: 0.2,
            opacity: 0.75
        )
        original.circleSelection.overrideColor = Color(
            red: 0.1,
            green: 0.7,
            blue: 0.5,
            opacity: 0.45
        )
        original.triangleSelection.cornerRadius = 11.5
        original.triangleSelection.strokeWidth = 5.25
        original.triangleSelection.strokeColor = Color(
            red: 0.1,
            green: 0.3,
            blue: 0.9,
            opacity: 0.85
        )
        original.triangleSelection.overrideColor = Color(
            red: 0.6,
            green: 0.2,
            blue: 0.8,
            opacity: 0.55
        )

        let serialized = try #require(original.asString())
        let restored = DefaultSelection(fromString: serialized)

        #expect(restored.rectSelection.cornerRadius == 14.25)
        #expect(restored.rectSelection.strokeWidth == 6.5)
        #expect(colorsApproximatelyMatch(
            restored.rectSelection.strokeColor,
            original.rectSelection.strokeColor
        ))
        #expect(colorsApproximatelyMatch(
            restored.rectSelection.overrideColor,
            original.rectSelection.overrideColor
        ))
        #expect(restored.circleSelection.strokeWidth == 8.75)
        #expect(colorsApproximatelyMatch(
            restored.circleSelection.strokeColor,
            original.circleSelection.strokeColor
        ))
        #expect(colorsApproximatelyMatch(
            restored.circleSelection.overrideColor,
            original.circleSelection.overrideColor
        ))
        #expect(restored.triangleSelection.cornerRadius == 11.5)
        #expect(restored.triangleSelection.strokeWidth == 5.25)
        #expect(colorsApproximatelyMatch(
            restored.triangleSelection.strokeColor,
            original.triangleSelection.strokeColor
        ))
        #expect(colorsApproximatelyMatch(
            restored.triangleSelection.overrideColor,
            original.triangleSelection.overrideColor
        ))
    }

    @Test
    func stringSerializationPreservesDisabledOptionalDefaults() throws {
        let serialized = try #require(DefaultSelection().asString())
        let restored = DefaultSelection(fromString: serialized)

        #expect(restored.rectSelection.strokeWidth == nil)
        #expect(restored.rectSelection.strokeColor == nil)
        #expect(restored.rectSelection.overrideColor == nil)
        #expect(restored.circleSelection.strokeWidth == nil)
        #expect(restored.circleSelection.strokeColor == nil)
        #expect(restored.circleSelection.overrideColor == nil)
        #expect(restored.triangleSelection.strokeWidth == nil)
        #expect(restored.triangleSelection.strokeColor == nil)
        #expect(restored.triangleSelection.overrideColor == nil)
    }

    @Test
    func nilAndMalformedStringsUseSafeDefaults() {
        for restored in [
            DefaultSelection(fromString: nil),
            DefaultSelection(fromString: "not JSON"),
            DefaultSelection(fromString: "{\"version\":999}")
        ] {
            #expect(restored.rectSelection.cornerRadius == 0)
            #expect(restored.rectSelection.strokeWidth == nil)
            #expect(restored.rectSelection.strokeColor == nil)
            #expect(restored.rectSelection.overrideColor == nil)
            #expect(restored.circleSelection.strokeWidth == nil)
            #expect(restored.circleSelection.strokeColor == nil)
            #expect(restored.circleSelection.overrideColor == nil)
            #expect(restored.triangleSelection.cornerRadius == 0)
            #expect(restored.triangleSelection.strokeWidth == nil)
            #expect(restored.triangleSelection.strokeColor == nil)
            #expect(restored.triangleSelection.overrideColor == nil)
        }
    }

    private func makeEditor(defaultSelection: DefaultSelection) -> DrawEditor {
        let renderer = ImageRenderer(
            content: Color.clear.frame(width: 100, height: 100)
        )
#if os(macOS)
        let image = renderer.nsImage!
#elseif os(iOS)
        let image = renderer.uiImage!
#endif
        let editor = DrawEditor(image: image, defaultSelection: defaultSelection)
        editor.canvasSize = CGSize(width: 500, height: 400)
        return editor
    }

    private func rectangle(from item: MarkupItems) throws -> RectanglePoint {
        guard case .rectangle(let rectangle) = item else {
            throw UnexpectedDefaultSelectionItemError()
        }
        return rectangle
    }

    private func circle(from item: MarkupItems) throws -> CirclePoint {
        guard case .circle(let circle) = item else {
            throw UnexpectedDefaultSelectionItemError()
        }
        return circle
    }

    private func triangle(from item: MarkupItems) throws -> TrianglePoint {
        guard case .triangle(let triangle) = item else {
            throw UnexpectedDefaultSelectionItemError()
        }
        return triangle
    }

    private func colorsMatch(_ lhs: Color?, _ rhs: Color) -> Bool {
        guard let lhs else { return false }
        return lhs.equals(rhs)
    }

    private func colorsApproximatelyMatch(_ lhs: Color?, _ rhs: Color?) -> Bool {
        guard let lhs = lhs?.rgba,
              let rhs = rhs?.rgba else { return lhs == nil && rhs == nil }

        return abs(lhs.r - rhs.r) < 0.001
            && abs(lhs.g - rhs.g) < 0.001
            && abs(lhs.b - rhs.b) < 0.001
            && abs(lhs.a - rhs.a) < 0.001
    }
}

private struct UnexpectedDefaultSelectionItemError: Error {}
