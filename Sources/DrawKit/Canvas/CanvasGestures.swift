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
        zoomAnchor: Binding<UnitPoint>,
        isMagnifying: Binding<Bool>,
        canvasSize: CGSize
    ) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if !isMagnifying.wrappedValue {
                    offset.wrappedValue = self.compensatedOffset(
                        offset.wrappedValue,
                        scale: scale.wrappedValue,
                        from: zoomAnchor.wrappedValue,
                        to: value.startAnchor,
                        canvasSize: canvasSize
                    )
                    zoomAnchor.wrappedValue = value.startAnchor
                    isMagnifying.wrappedValue = true
                }
                scale.wrappedValue = min(
                    max(lastScale.wrappedValue * value.magnification, 0.5),
                    5.0
                )
            }
            .onEnded { value in
                isMagnifying.wrappedValue = false
                lastScale.wrappedValue = scale.wrappedValue
            }
    }

    private func compensatedOffset(
        _ offset: CGSize,
        scale: CGFloat,
        from oldAnchor: UnitPoint,
        to newAnchor: UnitPoint,
        canvasSize: CGSize
    ) -> CGSize {
        let anchorDelta = CGSize(
            width: (oldAnchor.x - newAnchor.x) * canvasSize.width,
            height: (oldAnchor.y - newAnchor.y) * canvasSize.height
        )

        return CGSize(
            width: offset.width + (1 - scale) * anchorDelta.width,
            height: offset.height + (1 - scale) * anchorDelta.height
        )
    }
}
