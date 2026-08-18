//
//  CanvasNavigation.swift
//  DrawKit
//

import SwiftUI

enum CanvasNavigation {
    static let minimumScale: CGFloat = 0.5
    static let maximumScale: CGFloat = 20

    static func canvasLocation(
        for viewportLocation: CGPoint,
        canvasSize: CGSize,
        scale: CGFloat,
        offset: CGSize
    ) -> CGPoint {
        let canvasCenter = CGPoint(
            x: canvasSize.width / 2,
            y: canvasSize.height / 2
        )
        let safeScale = max(scale, 0.01)

        return CGPoint(
            x: canvasCenter.x
                + (viewportLocation.x - canvasCenter.x - offset.width) / safeScale,
            y: canvasCenter.y
                + (viewportLocation.y - canvasCenter.y - offset.height) / safeScale
        )
    }

    static func pannedOffset(
        from offset: CGSize,
        dx: CGFloat,
        dy: CGFloat,
        isMagnifying: Bool
    ) -> CGSize {
        guard !isMagnifying else { return offset }
        return CGSize(width: offset.width + dx, height: offset.height + dy)
    }

    static func magnifiedTransform(
        startScale: CGFloat,
        magnification: CGFloat,
        startOffset: CGSize,
        anchor: UnitPoint,
        canvasSize: CGSize
    ) -> (scale: CGFloat, offset: CGSize) {
        let scale = min(
            max(startScale * magnification, minimumScale),
            maximumScale
        )
        let scaleRatio = scale / max(startScale, 0.01)
        let pinchPoint = CGPoint(
            x: anchor.x * canvasSize.width,
            y: anchor.y * canvasSize.height
        )
        let canvasCenter = CGPoint(
            x: canvasSize.width / 2,
            y: canvasSize.height / 2
        )
        let offset = CGSize(
            width: startOffset.width + (1 - scaleRatio)
                * (pinchPoint.x - canvasCenter.x - startOffset.width),
            height: startOffset.height + (1 - scaleRatio)
                * (pinchPoint.y - canvasCenter.y - startOffset.height)
        )

        return (scale, offset)
    }
}
