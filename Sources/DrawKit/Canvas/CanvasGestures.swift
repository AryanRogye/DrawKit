//
//  CanvasGestures.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

final class CanvasGestures {
    func magnifyGesture(
        scale: Binding<CGFloat>,
        offset: Binding<CGSize>,
        lastScale: Binding<CGFloat>,
        magnificationStartOffset: Binding<CGSize>,
        isMagnifying: Binding<Bool>,
        canvasSize: CGSize
    ) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if !isMagnifying.wrappedValue {
                    magnificationStartOffset.wrappedValue = offset.wrappedValue
                    isMagnifying.wrappedValue = true
                }

                let startScale = lastScale.wrappedValue
                let newScale = min(
                    max(lastScale.wrappedValue * value.magnification, 0.5),
                    5.0
                )
                let scaleRatio = newScale / startScale
                let pinchPoint = CGPoint(
                    x: value.startAnchor.x * canvasSize.width,
                    y: value.startAnchor.y * canvasSize.height
                )
                let canvasCenter = CGPoint(
                    x: canvasSize.width / 2,
                    y: canvasSize.height / 2
                )
                let startOffset = magnificationStartOffset.wrappedValue

                // Keep the content beneath the pinch point stationary while scaling.
                offset.wrappedValue = CGSize(
                    width: startOffset.width + (1 - scaleRatio)
                        * (pinchPoint.x - canvasCenter.x - startOffset.width),
                    height: startOffset.height + (1 - scaleRatio)
                        * (pinchPoint.y - canvasCenter.y - startOffset.height)
                )
                scale.wrappedValue = newScale
            }
            .onEnded { _ in
                isMagnifying.wrappedValue = false
                lastScale.wrappedValue = scale.wrappedValue
            }
    }
}
