//
//  View+canvasNavigationGestures.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

extension View {
    func canvasNavigationGestures(
        scale: Binding<CGFloat>,
        offset: Binding<CGSize>,
        lastScale: Binding<CGFloat>,
        magnificationStartOffset: Binding<CGSize>,
        isMagnifying: Binding<Bool>,
        canvasSize: CGSize
    ) -> some View {
        self
            .modifier(
                GestureModifier(
                    scale: scale,
                    offset: offset,
                    lastScale: lastScale,
                    magnificationStartOffset: magnificationStartOffset,
                    isMagnifying: isMagnifying,
                    canvasSize: canvasSize
                )
            )
    }
}

private struct GestureModifier: ViewModifier {
    
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastScale: CGFloat
    @Binding var magnificationStartOffset: CGSize
    @Binding var isMagnifying: Bool
    let canvasSize: CGSize
    let gestures = CanvasGestures()
    
    func body(content: Content) -> some View {
        content
            .gesture(
                gestures.magnifyGesture(
                    scale: $scale,
                    offset: $offset,
                    lastScale: $lastScale,
                    magnificationStartOffset: $magnificationStartOffset,
                    isMagnifying: $isMagnifying,
                    canvasSize: canvasSize
                )
            )
            .omnidirectionalPanGesture { dx, dy, phase in
                offset = CanvasNavigation.pannedOffset(
                    from: offset,
                    dx: dx,
                    dy: dy,
                    isMagnifying: isMagnifying
                )
            }
    }
}
