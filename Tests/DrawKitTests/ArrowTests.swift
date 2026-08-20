import CoreGraphics
import SwiftUI
import Testing
@testable import DrawKit

@MainActor
struct ArrowTests {
    @Test
    func shapePointsUpAtZeroDegrees() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let path = ArrowShape().path(in: rect)

        #expect(path.boundingRect == rect)
        #expect(path.contains(CGPoint(x: 50, y: 5)))
        #expect(!path.contains(CGPoint(x: 95, y: 50)))
    }

    @Test
    func placementCreatesArrowAndRecordsHistory() throws {
        let editor = makeEditor()
        editor.canvasSize = CGSize(width: 200, height: 120)

        editor.select(.arrow, with: .blue)
        #expect(editor.items.isEmpty)
        #expect(editor.selectedHoverItem == .arrow)

        editor.placeSelectedTool(at: CGPoint(x: 100, y: 60))

        let arrow = try arrow(from: #require(editor.items.first))
        #expect(editor.activeTool.kind == .arrow)
        #expect(arrow.color.equals(.blue))
        #expect(arrow.rotation == .zero)
        #expect(arrow.cornerRadius == 0)
        #expect(arrow.strokeWidth == nil)
        #expect(arrow.strokeColor == nil)

        editor.undo()
        #expect(editor.items.isEmpty)

        editor.redo()
        #expect(editor.items.count == 1)
        #expect(editor.items[0].kind == .arrow)
    }

    @Test
    func selectedArrowColorChangePreservesAppearanceAndIsUndoable() throws {
        let original = makeArrow(
            color: .blue,
            strokeWidth: 3,
            strokeColor: .red,
            cornerRadius: 7,
            rotation: .degrees(45)
        )
        let editor = makeEditor(items: [.arrow(original)])
        editor.canvasSelected = CanvasSelection(index: 0, id: original.id)

        editor.changeSelectedColorIfNeeded(.green)

        let changed = try arrow(from: editor.items[0])
        #expect(changed.id == original.id)
        #expect(changed.rect == original.rect)
        #expect(changed.color.equals(.green))
        #expect(changed.strokeWidth == 3)
        #expect(changed.strokeColor?.equals(.red) == true)
        #expect(changed.cornerRadius == 7)
        #expect(changed.rotation == .degrees(45))

        editor.undo()
        let restored = try arrow(from: editor.items[0])
        #expect(restored.color.equals(.blue))
    }

    @Test
    func appearanceControlsUpdateArrowAndRecordHistory() throws {
        let original = makeArrow()
        let editor = makeEditor(items: [.arrow(original)])

        editor.setStroke(width: 4, color: .orange, at: 0)
        editor.setCornerRadius(9, at: 0)
        editor.setOpacity(0.4, at: 0)

        let changed = try arrow(from: editor.items[0])
        #expect(changed.strokeWidth == 4)
        #expect(changed.strokeColor?.equals(.orange) == true)
        #expect(changed.cornerRadius == 9)
        #expect(abs(changed.color.alpha - 0.4) < 0.001)
        #expect(editor.history.undoSnapshots.count == 3)

        editor.undo()
        let opaque = try arrow(from: editor.items[0])
        #expect(abs(opaque.color.alpha - 1) < 0.001)

        editor.undo()
        let square = try arrow(from: editor.items[0])
        #expect(square.cornerRadius == 0)

        editor.undo()
        let unstroked = try arrow(from: editor.items[0])
        #expect(unstroked.strokeWidth == nil)
        #expect(unstroked.strokeColor == nil)
    }

    @Test
    func mappingPreservesArrowAppearanceAndIdentity() {
        let original = makeArrow(
            rect: CGRect(x: 10, y: 15, width: 20, height: 10),
            color: .purple,
            strokeWidth: 2,
            strokeColor: .black,
            cornerRadius: 5,
            rotation: .degrees(90)
        )

        let mapped = original.mapped(
            from: CGRect(x: 0, y: 0, width: 100, height: 50),
            to: CGRect(x: 0, y: 0, width: 200, height: 100)
        )

        #expect(mapped.id == original.id)
        #expect(mapped.rect == CGRect(x: 20, y: 30, width: 40, height: 20))
        #expect(mapped.color.equals(.purple))
        #expect(mapped.strokeWidth == 2)
        #expect(mapped.strokeColor?.equals(.black) == true)
        #expect(mapped.cornerRadius == 5)
        #expect(mapped.rotation == .degrees(90))
    }

    private func makeEditor(items: [MarkupItems] = []) -> DrawEditor {
        let renderer = ImageRenderer(
            content: Color.clear.frame(width: 100, height: 100)
        )
#if os(macOS)
        let image = renderer.nsImage!
#elseif os(iOS)
        let image = renderer.uiImage!
#endif
        let editor = DrawEditor(image: image)
        editor.items = items
        return editor
    }

    private func makeArrow(
        rect: CGRect = CGRect(x: 10, y: 20, width: 80, height: 120),
        color: Color = .blue,
        strokeWidth: CGFloat? = nil,
        strokeColor: Color? = nil,
        cornerRadius: CGFloat = 0,
        rotation: Angle = .zero
    ) -> ArrowPoint {
        ArrowPoint(
            rect: rect,
            color: color,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            cornerRadius: cornerRadius,
            rotation: rotation
        )
    }

    private func arrow(from item: MarkupItems) throws -> ArrowPoint {
        guard case .arrow(let arrow) = item else {
            throw UnexpectedArrowItemError()
        }
        return arrow
    }
}

private struct UnexpectedArrowItemError: Error {}
