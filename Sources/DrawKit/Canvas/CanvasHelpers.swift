//
//  CanvasHelpers.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

enum CanvasHelpers {
    static func fittedImageRect(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0,
              containerSize.width > 0, containerSize.height > 0 else { return .zero }
        
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        var fitSize = containerSize
        if imageAspect > containerAspect {
            // image is relatively wider -> width-constrained
            fitSize.height = containerSize.width / imageAspect
        } else {
            // image is relatively taller -> height-constrained
            fitSize.width = containerSize.height * imageAspect
        }
        
        let origin = CGPoint(
            x: (containerSize.width - fitSize.width) / 2,
            y: (containerSize.height - fitSize.height) / 2
        )
        return CGRect(origin: origin, size: fitSize)
    }
}
