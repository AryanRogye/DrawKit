import CoreGraphics
import SwiftUI
import Testing
@testable import DrawKit

@MainActor
struct DrawEditorEraserTests {
    @Test
    func eraserAndPenShareSelectedThickness() throws {
        let editor = makeEditor()
        editor.canvasSize = CGSize(width: 100, height: 100)
        editor.changePenLineWidth(to: 12)

        editor.select(.eraser, with: .black)

        #expect(editor.selectedItem.kind == .eraser)
        #expect(editor.lineWidth == 12)

        editor.select(.pen, with: .black)
        let selectedPen = try penStroke(from: editor.selectedItem)
        #expect(selectedPen.lineWidth == 12)
    }

    @Test
    func erasesOnlyIntersectingPortionOfPenStroke() throws {
        let editor = makeEditor(items: [
            .pen(PenStroke(
                id: UUID(),
                points: [CGPoint(x: 0, y: 10), CGPoint(x: 100, y: 10)],
                color: .red,
                lineWidth: 2
            ))
        ])

        editor.erasePenStrokes(
            from: CGPoint(x: 50, y: 0),
            to: CGPoint(x: 50, y: 20),
            width: 10
        )

        #expect(editor.items.count == 2)
        let strokes = try editor.items.map(penStroke(from:))
        #expect(strokes[0].points.first?.x == 0)
        #expect(abs(try #require(strokes[0].points.last?.x) - 44) < 0.001)
        #expect(abs(try #require(strokes[1].points.first?.x) - 56) < 0.001)
        #expect(strokes[1].points.last?.x == 100)
    }

    @Test
    func eraserWidthUsesSharedLineWidth() throws {
        let editor = makeEditor(items: [
            .pen(PenStroke(
                id: UUID(),
                points: [CGPoint(x: 0, y: 10), CGPoint(x: 100, y: 10)],
                color: .black,
                lineWidth: 2
            ))
        ])

        editor.erasePenStrokes(
            from: CGPoint(x: 0, y: 0),
            to: CGPoint(x: 100, y: 0),
            width: 12
        )
        #expect(editor.items.count == 1)

        editor.erasePenStrokes(
            from: CGPoint(x: 0, y: 0),
            to: CGPoint(x: 100, y: 0),
            width: 20
        )
        #expect(editor.items.isEmpty)
    }

    @Test
    func doesNotEraseShapes() {
        let rectangle = RectanglePoint(
            rect: CGRect(x: 0, y: 0, width: 100, height: 100),
            color: .blue,
            cornerRadius: 0,
            strokeWidth: nil,
            strokeColor: nil,
            rotation: .zero
        )
        let editor = makeEditor(items: [.rectangle(rectangle)])

        editor.erasePenStrokes(
            from: CGPoint(x: 0, y: 50),
            to: CGPoint(x: 100, y: 50),
            width: 12
        )

        #expect(editor.items == [.rectangle(rectangle)])
    }

    @Test
    func leavesDistantStrokeUnchanged() throws {
        let id = UUID()
        let editor = makeEditor(items: [
            .pen(PenStroke(
                id: id,
                points: [CGPoint(x: 0, y: 50), CGPoint(x: 100, y: 50)],
                color: .black,
                lineWidth: 2
            ))
        ])

        editor.erasePenStrokes(
            from: CGPoint(x: 0, y: 0),
            to: CGPoint(x: 100, y: 0),
            width: 12
        )

        #expect(editor.items.count == 1)
        #expect(try penStroke(from: editor.items[0]).id == id)
    }

    private func makeEditor(items: [MarkupItems] = []) -> DrawEditor {
        let renderer = ImageRenderer(content: Color.clear.frame(width: 1, height: 1))
#if os(macOS)
        let image = renderer.nsImage!
#elseif os(iOS)
        let image = renderer.uiImage!
#endif
        let editor = DrawEditor(image: image)
        editor.items = items
        return editor
    }

    private func penStroke(from item: MarkupItems) throws -> PenStroke {
        guard case .pen(let stroke) = item else {
            throw UnexpectedItemError()
        }
        return stroke
    }
}

private struct UnexpectedItemError: Error {}
