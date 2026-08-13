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
        onSave: @escaping (NSImage?) -> Void
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
        _ imageCompletion: @escaping (NSImage?) -> Void
    ) -> some View {
        self.onChange(of: didTriggerSave.wrappedValue) { _, shouldSave in
            if shouldSave {
                guard canvasSize.width > 0,
                      canvasSize.height > 0,
                      imageRect.width > 0,
                      imageRect.height > 0,
                      outputSize.width > 0,
                      outputSize.height > 0 else {
                    imageCompletion(nil)
                    didTriggerSave.wrappedValue = false
                    return
                }
                
                let cropOffset = CGSize(
                    width: (canvasSize.width / 2) - imageRect.midX,
                    height: (canvasSize.height / 2) - imageRect.midY
                )
                
                let exportView = self
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    .offset(cropOffset)
                    .frame(width: imageRect.width, height: imageRect.height)
                    .clipped()
                
                let renderer = ImageRenderer(content: exportView)
                renderer.proposedSize = ProposedViewSize(imageRect.size)
                
                // Render the fitted image area at the source image's resolution.
                renderer.scale = outputSize.width / imageRect.width
                
                if let nsImage = renderer.nsImage,
                   let tiffData = nsImage.tiffRepresentation,
                   let bitmap = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmap.representation(using: .png, properties: [:]) {
                    
                    imageCompletion(NSImage(data: pngData))
                } else {
                    imageCompletion(nil)
                }
                didTriggerSave.wrappedValue = false
            }
        }
    }
}
