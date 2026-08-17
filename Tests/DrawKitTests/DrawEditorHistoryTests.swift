import CoreGraphics
import SwiftUI
import Testing
@testable import DrawKit

@MainActor
struct DrawEditorHistoryTests {
    @Test
    func undoAndRedoRestoreMultipleEditsInOrder() {
        let editor = makeEditor()
        let first = MarkupItems.rectangle(makeRectangle(x: 10))
        let second = MarkupItems.rectangle(makeRectangle(x: 30))

        editor.performHistoryMutation { editor.items.append(first) }
        editor.performHistoryMutation { editor.items.append(second) }

        editor.undo()
        #expect(editor.items == [first])

        editor.undo()
        #expect(editor.items.isEmpty)

        editor.redo()
        #expect(editor.items == [first])

        editor.redo()
        #expect(editor.items == [first, second])
    }

    @Test
    func emptyHistoryCallsDoNothing() {
        let editor = makeEditor()

        editor.undo()
        editor.redo()

        #expect(editor.items.isEmpty)
    }

    @Test
    func newEditClearsRedoHistory() {
        let editor = makeEditor()
        let first = MarkupItems.rectangle(makeRectangle(x: 10))
        let replacement = MarkupItems.rectangle(makeRectangle(x: 50))

        editor.performHistoryMutation { editor.items.append(first) }
        editor.undo()
        editor.performHistoryMutation { editor.items.append(replacement) }
        editor.redo()

        #expect(editor.items == [replacement])
    }

    @Test
    func historyLimitDropsOldestSnapshots() {
        let editor = makeEditor(historyLimit: 2)

        for x in [10.0, 20.0, 30.0] {
            editor.performHistoryMutation {
                editor.items.append(.rectangle(makeRectangle(x: x)))
            }
        }

        editor.undo()
        editor.undo()
        editor.undo()

        #expect(editor.items.count == 1)
        #expect(editor.items[0].shapePoint?.rect.minX == 10)
    }

    @Test
    func transactionCreatesOneHistoryStepAndIgnoresNoOp() {
        let editor = makeEditor()
        let item = MarkupItems.rectangle(makeRectangle(x: 10))

        editor.beginHistoryTransaction()
        editor.items.append(item)
        editor.setOpacity(0.8, at: 0)
        editor.setCornerRadius(8, at: 0)
        editor.commitHistoryTransaction()

        #expect(editor.history.undoSnapshots.count == 1)
        editor.undo()
        #expect(editor.items.isEmpty)

        editor.beginHistoryTransaction()
        editor.commitHistoryTransaction()
        #expect(editor.history.undoSnapshots.isEmpty)
    }

    @Test
    func appearanceChangesAndDeletionAreUndoable() throws {
        let originalRectangle = makeRectangle(x: 10)
        let editor = makeEditor(items: [.rectangle(originalRectangle)])
        editor.canvasSelected = CanvasSelection(index: 0, id: originalRectangle.id)

        editor.setStroke(width: 4, color: .red, at: 0)
        editor.setCornerRadius(6, at: 0)
        editor.setOpacity(0.5, at: 0)
        editor.deleteSelectedItem()

        #expect(editor.items.isEmpty)
        editor.undo()
        #expect(editor.items.count == 1)

        editor.undo()
        let opaque = try rectangle(from: editor.items[0])
        #expect(opaque.color.alpha == 1)

        editor.undo()
        let square = try rectangle(from: editor.items[0])
        #expect(square.cornerRadius == 0)

        editor.undo()
        let unstroked = try rectangle(from: editor.items[0])
        #expect(unstroked.strokeWidth == nil)
        #expect(unstroked.strokeColor == nil)
    }

    @Test
    func selectingShapeRecordsItsCreation() {
        let editor = makeEditor()
        editor.canvasSize = CGSize(width: 100, height: 100)

        editor.select(.rectangle, with: .blue)
        #expect(editor.items.count == 1)

        editor.undo()
        #expect(editor.items.isEmpty)

        editor.redo()
        #expect(editor.items.count == 1)
    }

    @Test
    func completePenStrokeIsOneUndoStep() throws {
        let editor = makeEditor()
        editor.selectedItem = .pen(PenStroke(
            id: UUID(),
            points: [],
            color: .black,
            lineWidth: 3
        ))

        let index = try #require(editor.beginPenStroke(at: CGPoint(x: 1, y: 2)))
        editor.appendPenPoint(CGPoint(x: 3, y: 4), at: index)
        editor.appendPenPoint(CGPoint(x: 5, y: 6), at: index)
        editor.endPenStroke()

        #expect(editor.history.undoSnapshots.count == 1)
        editor.undo()
        #expect(editor.items.isEmpty)
        editor.redo()
        #expect(editor.items.count == 1)
    }

    @Test
    func eraserDragIsOneUndoStep() {
        let original = MarkupItems.pen(PenStroke(
            id: UUID(),
            points: [CGPoint(x: 0, y: 10), CGPoint(x: 100, y: 10)],
            color: .black,
            lineWidth: 2
        ))
        let editor = makeEditor(items: [original])

        editor.beginHistoryTransaction()
        editor.erasePenStrokes(
            from: CGPoint(x: 40, y: 0),
            to: CGPoint(x: 40, y: 20),
            width: 8
        )
        editor.erasePenStrokes(
            from: CGPoint(x: 60, y: 0),
            to: CGPoint(x: 60, y: 20),
            width: 8
        )
        editor.commitHistoryTransaction()

        #expect(editor.history.undoSnapshots.count == 1)
        editor.undo()
        #expect(editor.items == [original])
    }

    @Test
    func undoKeepsToolSettingsAndReconcilesSelection() {
        let first = makeRectangle(x: 10)
        let second = makeRectangle(x: 30)
        let editor = makeEditor(items: [.rectangle(first), .rectangle(second)])
        editor.canvasSelected = CanvasSelection(index: 1, id: second.id)
        editor.lineWidth = 7

        editor.performHistoryMutation {
            editor.items.removeFirst()
        }
        editor.undo()

        #expect(editor.lineWidth == 7)
        #expect(editor.canvasSelected == CanvasSelection(index: 1, id: second.id))

        editor.redo()
        #expect(editor.canvasSelected == CanvasSelection(index: 0, id: second.id))
    }

    @Test
    func resizingRemapsCurrentAndHistoricalSnapshots() throws {
        let initial = MarkupItems.rectangle(makeRectangle(x: 10))
        let editor = makeEditor(items: [initial])
        editor.updateCanvasSize(CGSize(width: 100, height: 100))

        editor.performHistoryMutation {
            guard case .rectangle(var rectangle) = editor.items[0] else { return }
            rectangle.rect.origin.x = 20
            editor.items[0] = .rectangle(rectangle)
        }
        editor.updateCanvasSize(CGSize(width: 200, height: 200))

        editor.undo()
        let undone = try rectangle(from: editor.items[0])
        #expect(abs(undone.rect.minX - 20) < 0.001)

        editor.redo()
        let redone = try rectangle(from: editor.items[0])
        #expect(abs(redone.rect.minX - 40) < 0.001)
    }

    private func makeEditor(
        items: [MarkupItems] = [],
        historyLimit: Int = 100
    ) -> DrawEditor {
        let renderer = ImageRenderer(content: Color.clear.frame(width: 1, height: 1))
#if os(macOS)
        let image = renderer.nsImage!
#elseif os(iOS)
        let image = renderer.uiImage!
#endif
        let editor = DrawEditor(image: image, historyLimit: historyLimit)
        editor.items = items
        return editor
    }

    private func makeRectangle(x: CGFloat) -> RectanglePoint {
        RectanglePoint(
            rect: CGRect(x: x, y: 10, width: 20, height: 20),
            color: .blue,
            cornerRadius: 0,
            strokeWidth: nil,
            strokeColor: nil,
            rotation: .zero
        )
    }

    private func rectangle(from item: MarkupItems) throws -> RectanglePoint {
        guard case .rectangle(let rectangle) = item else {
            throw UnexpectedHistoryItemError()
        }
        return rectangle
    }
}

private struct UnexpectedHistoryItemError: Error {}
