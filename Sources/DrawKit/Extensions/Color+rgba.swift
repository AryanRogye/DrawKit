//
//  Color+rgba.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/13/26.
//

import SwiftUI

extension Color {
    
    struct RGBA: Equatable {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
    }
    
    var rgba: RGBA? {
        let systemColor = SystemColor(self)
        
#if os(macOS)
        guard let rgb = systemColor.usingColorSpace(.deviceRGB) else {
            return nil
        }
        
        let red = rgb.redComponent
        let green = rgb.greenComponent
        let blue = rgb.blueComponent
        let alpha = rgb.alphaComponent
        
        return RGBA(r: red, g: green, b: blue, a: alpha)
#elseif os(iOS)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard systemColor.getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        ) else {
            return nil
        }
        
        return RGBA(r: red, g: green, b: blue, a: alpha)
#endif
    }
    
}
