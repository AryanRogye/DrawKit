//
//  View+saveCompositeView.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

extension View {
    func saveView(
        save: Binding<Bool>,
        canvasSize: CGSize,
        imageSize: CGSize,
        beforeSave: (@escaping () -> Void) = { },
        afterSave: (@escaping () -> Void) = { },
        onSave: @escaping (SystemImage?) -> Void
    ) -> some View {
        self
            .saveCompositeView(
                didTriggerSave: save,
                canvasSize: canvasSize,
                imageRect: CanvasHelpers.fittedImageRect(
                    imageSize: imageSize,
                    in: canvasSize
                ),
                outputSize: imageSize,
                beforeSave: beforeSave,
                afterSave: afterSave,
                onSave
            )
    }
}

private extension View {
    func saveCompositeView(
        didTriggerSave: Binding<Bool>,
        canvasSize: CGSize,
        imageRect: CGRect,
        outputSize: CGSize,
        beforeSave: (@escaping () -> Void),
        afterSave: (@escaping () -> Void),
        _ imageCompletion: @escaping (SystemImage?) -> Void
    ) -> some View {
        self.onChange(of: didTriggerSave.wrappedValue) { _, shouldSave in
            guard shouldSave else { return }
            guard let configuration = CompositeRenderConfiguration(
                canvasSize: canvasSize,
                imageRect: imageRect,
                outputSize: outputSize
            ) else {
                imageCompletion(nil)
                didTriggerSave.wrappedValue = false
                return
            }

            beforeSave()
            imageCompletion(CompositeRenderer.render(
                content: self,
                configuration: configuration
            ))
            afterSave()
            didTriggerSave.wrappedValue = false
        }
    }
}

struct CompositeRenderConfiguration {
    let canvasSize: CGSize
    let imageRect: CGRect
    let outputSize: CGSize

    init?(canvasSize: CGSize, imageRect: CGRect, outputSize: CGSize) {
        guard canvasSize.width > 0,
              canvasSize.height > 0,
              imageRect.width > 0,
              imageRect.height > 0,
              outputSize.width > 0,
              outputSize.height > 0 else { return nil }

        self.canvasSize = canvasSize
        self.imageRect = imageRect
        self.outputSize = outputSize
    }

    var cropOffset: CGSize {
        CGSize(
            width: (canvasSize.width / 2) - imageRect.midX,
            height: (canvasSize.height / 2) - imageRect.midY
        )
    }

    var rendererScale: CGFloat {
        outputSize.width / imageRect.width
    }
}

@MainActor
enum CompositeRenderer {
    static func render<Content: View>(
        content: Content,
        configuration: CompositeRenderConfiguration
    ) -> SystemImage? {
        let exportView = content
            .frame(
                width: configuration.canvasSize.width,
                height: configuration.canvasSize.height
            )
            .offset(configuration.cropOffset)
            .frame(
                width: configuration.imageRect.width,
                height: configuration.imageRect.height
            )
            .clipped()

        let renderer = ImageRenderer(content: exportView)
        renderer.proposedSize = ProposedViewSize(configuration.imageRect.size)
        renderer.scale = configuration.rendererScale

#if os(macOS)
        guard let image = renderer.nsImage,
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        return NSImage(data: pngData)
#elseif os(iOS)
        return renderer.uiImage
#endif
    }
}
