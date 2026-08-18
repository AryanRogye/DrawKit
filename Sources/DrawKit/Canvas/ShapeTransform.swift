//
//  ShapeTransform.swift
//  DrawKit
//

import SwiftUI

enum ShapeTransform {
    static func rotation(
        around center: CGPoint,
        toward location: CGPoint,
        detents: [Angle],
        threshold: Double
    ) -> Angle {
        let dx = location.x - center.x
        let dy = location.y - center.y
        let rotation = Angle(radians: atan2(dy, dx) + .pi / 2)

        return detents.first {
            rotation.inThreshold(of: $0, threshold: threshold)
        } ?? rotation
    }

    static func resizedRect(
        from rect: CGRect,
        canvasTranslation: CGSize,
        rotation: Angle,
        handle: ResizeHandle,
        minimumSize: CGFloat = 5
    ) -> CGRect {
        let cosine = CGFloat(cos(rotation.radians))
        let sine = CGFloat(sin(rotation.radians))
        let localTranslation = CGSize(
            width: canvasTranslation.width * cosine + canvasTranslation.height * sine,
            height: -canvasTranslation.width * sine + canvasTranslation.height * cosine
        )

        var width = rect.width
        var height = rect.height
        var localCenterShift = CGSize.zero

        if handle.movesLeft {
            width = max(rect.width - localTranslation.width, minimumSize)
            localCenterShift.width = (rect.width - width) / 2
        } else if handle.movesRight {
            width = max(rect.width + localTranslation.width, minimumSize)
            localCenterShift.width = (width - rect.width) / 2
        }

        if handle.movesTop {
            height = max(rect.height - localTranslation.height, minimumSize)
            localCenterShift.height = (rect.height - height) / 2
        } else if handle.movesBottom {
            height = max(rect.height + localTranslation.height, minimumSize)
            localCenterShift.height = (height - rect.height) / 2
        }

        let centerShift = CGSize(
            width: localCenterShift.width * cosine - localCenterShift.height * sine,
            height: localCenterShift.width * sine + localCenterShift.height * cosine
        )
        let center = CGPoint(
            x: rect.midX + centerShift.width,
            y: rect.midY + centerShift.height
        )

        return CGRect(
            x: center.x - width / 2,
            y: center.y - height / 2,
            width: width,
            height: height
        )
    }
}
