import CoreGraphics
import SwiftUI
import Testing
@testable import DrawKit

@MainActor
struct ShapeTransformTests {
    @Test
    func rightResizeKeepsOppositeEdgeFixed() {
        let resized = ShapeTransform.resizedRect(
            from: CGRect(x: 10, y: 20, width: 100, height: 60),
            canvasTranslation: CGSize(width: 20, height: 0),
            rotation: .zero,
            handle: .right
        )

        #expect(resized == CGRect(x: 10, y: 20, width: 120, height: 60))
    }

    @Test
    func resizeClampsToMinimumSize() {
        let resized = ShapeTransform.resizedRect(
            from: CGRect(x: 10, y: 20, width: 100, height: 60),
            canvasTranslation: CGSize(width: -200, height: 0),
            rotation: .zero,
            handle: .right
        )

        #expect(resized == CGRect(x: 10, y: 20, width: 5, height: 60))
    }

    @Test
    func rotatedResizeConvertsCanvasTranslationToLocalSpace() {
        let resized = ShapeTransform.resizedRect(
            from: CGRect(x: 0, y: 0, width: 100, height: 60),
            canvasTranslation: CGSize(width: 0, height: 20),
            rotation: .degrees(90),
            handle: .right
        )

        #expect(abs(resized.minX + 10) < 0.001)
        #expect(abs(resized.minY - 10) < 0.001)
        #expect(abs(resized.width - 120) < 0.001)
        #expect(abs(resized.height - 60) < 0.001)
    }

    @Test
    func rotationUsesTopAsZeroAndSnapsToDetents() {
        let center = CGPoint(x: 50, y: 50)
        let detents: [Angle] = [.degrees(0), .degrees(45), .degrees(90)]

        let top = ShapeTransform.rotation(
            around: center,
            toward: CGPoint(x: 50, y: 0),
            detents: detents,
            threshold: 2
        )
        let right = ShapeTransform.rotation(
            around: center,
            toward: CGPoint(x: 100, y: 50),
            detents: detents,
            threshold: 2
        )

        #expect(top == .degrees(0))
        #expect(right == .degrees(90))
    }
}
