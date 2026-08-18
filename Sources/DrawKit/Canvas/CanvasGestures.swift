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

                let transform = CanvasNavigation.magnifiedTransform(
                    startScale: lastScale.wrappedValue,
                    magnification: value.magnification,
                    startOffset: magnificationStartOffset.wrappedValue,
                    anchor: value.startAnchor,
                    canvasSize: canvasSize
                )
                offset.wrappedValue = transform.offset
                scale.wrappedValue = transform.scale
            }
            .onEnded { _ in
                isMagnifying.wrappedValue = false
                lastScale.wrappedValue = scale.wrappedValue
            }
    }
}
