import CoreGraphics
import SwiftUI
import Testing
@testable import DrawKit

@MainActor
struct CanvasNavigationTests {
    @Test
    func panAccumulatesBothAxes() {
        let offset = CanvasNavigation.pannedOffset(
            from: CGSize(width: 10, height: -5),
            dx: 4,
            dy: -3,
            isMagnifying: false
        )

        #expect(offset == CGSize(width: 14, height: -8))
    }

    @Test
    func panIsIgnoredDuringMagnification() {
        let original = CGSize(width: 10, height: -5)
        let offset = CanvasNavigation.pannedOffset(
            from: original,
            dx: 40,
            dy: 30,
            isMagnifying: true
        )

        #expect(offset == original)
    }

    @Test
    func centerAnchoredZoomKeepsOffsetStable() {
        let transform = CanvasNavigation.magnifiedTransform(
            startScale: 1,
            magnification: 2,
            startOffset: .zero,
            anchor: .center,
            canvasSize: CGSize(width: 200, height: 100)
        )

        #expect(transform.scale == 2)
        #expect(transform.offset == .zero)
    }

    @Test
    func offCenterZoomKeepsPinchContentStationary() {
        let canvasSize = CGSize(width: 200, height: 100)
        let anchor = UnitPoint(x: 0.25, y: 0.25)
        let anchorLocation = CGPoint(
            x: anchor.x * canvasSize.width,
            y: anchor.y * canvasSize.height
        )
        let before = CanvasNavigation.canvasLocation(
            for: anchorLocation,
            canvasSize: canvasSize,
            scale: 1,
            offset: .zero
        )
        let transform = CanvasNavigation.magnifiedTransform(
            startScale: 1,
            magnification: 2,
            startOffset: .zero,
            anchor: anchor,
            canvasSize: canvasSize
        )
        let after = CanvasNavigation.canvasLocation(
            for: anchorLocation,
            canvasSize: canvasSize,
            scale: transform.scale,
            offset: transform.offset
        )

        #expect(after == before)
    }

    @Test
    func zoomClampsAtSupportedLimits() {
        let maximum = CanvasNavigation.magnifiedTransform(
            startScale: 10,
            magnification: 10,
            startOffset: .zero,
            anchor: .center,
            canvasSize: CGSize(width: 100, height: 100)
        )
        let minimum = CanvasNavigation.magnifiedTransform(
            startScale: 1,
            magnification: 0.01,
            startOffset: .zero,
            anchor: .center,
            canvasSize: CGSize(width: 100, height: 100)
        )

        #expect(maximum.scale == CanvasNavigation.maximumScale)
        #expect(minimum.scale == CanvasNavigation.minimumScale)
    }
}
