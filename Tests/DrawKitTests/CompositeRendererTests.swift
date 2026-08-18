import SwiftUI
import Testing
@testable import DrawKit

@MainActor
struct CompositeRendererTests {
    @Test
    func rendersAtRequestedOutputResolution() throws {
        let configuration = try #require(CompositeRenderConfiguration(
            canvasSize: CGSize(width: 100, height: 100),
            imageRect: CGRect(x: 0, y: 25, width: 100, height: 50),
            outputSize: CGSize(width: 200, height: 100)
        ))

        let image = try #require(CompositeRenderer.render(
            content: Color.red,
            configuration: configuration
        ))

#if os(macOS)
        let representation = try #require(
            image.representations.compactMap { $0 as? NSBitmapImageRep }.first
        )
        #expect(representation.pixelsWide == 200)
        #expect(representation.pixelsHigh == 100)
        let centerColor = try #require(representation.colorAt(x: 100, y: 50))
        #expect(centerColor.redComponent > 0.9)
        #expect(centerColor.redComponent > centerColor.greenComponent + 0.5)
        #expect(centerColor.redComponent > centerColor.blueComponent + 0.5)
#elseif os(iOS)
        let cgImage = try #require(image.cgImage)
        #expect(cgImage.width == 200)
        #expect(cgImage.height == 100)
#endif
    }

    @Test
    func rejectsInvalidRenderDimensions() {
        #expect(CompositeRenderConfiguration(
            canvasSize: CGSize(width: 100, height: 100),
            imageRect: .zero,
            outputSize: CGSize(width: 200, height: 100)
        ) == nil)
    }

    @Test
    func computesCropAndRendererScale() throws {
        let configuration = try #require(CompositeRenderConfiguration(
            canvasSize: CGSize(width: 300, height: 200),
            imageRect: CGRect(x: 30, y: 50, width: 240, height: 100),
            outputSize: CGSize(width: 960, height: 400)
        ))

        #expect(configuration.cropOffset == .zero)
        #expect(configuration.rendererScale == 4)
    }
}
