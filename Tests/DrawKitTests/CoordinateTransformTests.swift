import CoreGraphics
import SwiftUI
import Testing
@testable import DrawKit

@MainActor
struct CoordinateTransformTests {
    @Test
    func fittedImageRectLetterboxesWideImage() {
        let rect = CanvasHelpers.fittedImageRect(
            imageSize: CGSize(width: 400, height: 200),
            in: CGSize(width: 300, height: 300)
        )

        #expect(rect == CGRect(x: 0, y: 75, width: 300, height: 150))
    }

    @Test
    func fittedImageRectPillarboxesTallImage() {
        let rect = CanvasHelpers.fittedImageRect(
            imageSize: CGSize(width: 200, height: 400),
            in: CGSize(width: 300, height: 300)
        )

        #expect(rect == CGRect(x: 75, y: 0, width: 150, height: 300))
    }

    @Test
    func viewportLocationAccountsForPanAndZoom() {
        let location = CanvasNavigation.canvasLocation(
            for: CGPoint(x: 150, y: 100),
            canvasSize: CGSize(width: 200, height: 200),
            scale: 2,
            offset: CGSize(width: 10, height: -20)
        )

        #expect(location == CGPoint(x: 120, y: 110))
    }

    @Test
    func remapsShapesAndPenPointsBetweenFittedRects() throws {
        let id = UUID()
        let rectangle = RectanglePoint(
            id: id,
            rect: CGRect(x: 25, y: 35, width: 20, height: 10),
            color: .blue,
            cornerRadius: 3,
            strokeWidth: 2,
            strokeColor: .black,
            rotation: .degrees(45)
        )
        let stroke = PenStroke(
            id: UUID(),
            points: [CGPoint(x: 25, y: 35), CGPoint(x: 45, y: 45)],
            color: .red,
            lineWidth: 4
        )

        let mapped = [MarkupItems.rectangle(rectangle), .pen(stroke)].mapped(
            from: CGRect(x: 0, y: 25, width: 100, height: 50),
            to: CGRect(x: 0, y: 50, width: 200, height: 100)
        )

        guard case .rectangle(let mappedRectangle) = mapped[0],
              case .pen(let mappedStroke) = mapped[1] else {
            Issue.record("Expected mapped rectangle and pen stroke")
            return
        }
        #expect(mappedRectangle.id == id)
        #expect(mappedRectangle.rect == CGRect(x: 50, y: 70, width: 40, height: 20))
        #expect(mappedRectangle.rotation == .degrees(45))
        #expect(mappedStroke.points == [CGPoint(x: 50, y: 70), CGPoint(x: 90, y: 90)])
        #expect(mappedStroke.lineWidth == 4)
    }
}
