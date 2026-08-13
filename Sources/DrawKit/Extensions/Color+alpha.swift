//
//  Color+alpha.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

extension Color {
    var alpha: Double {
        let nsColor = NSColor(self)
        
        guard let rgb = nsColor.usingColorSpace(.deviceRGB) else {
            return 1
        }
        
        return Double(rgb.alphaComponent)
    }

    func replacingAlpha(with alpha: Double) -> Color {
        Color(NSColor(self).withAlphaComponent(alpha))
    }
}
