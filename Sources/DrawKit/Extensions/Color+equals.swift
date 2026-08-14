//
//  Color+equals.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/13/26.
//

import SwiftUI

extension Color {
    func equals(_ color: Color, ignoreAlpha: Bool = false) -> Bool {
        guard let s_rgba = self.rgba,
              let c_rgba = color.rgba else {
            return false
        }
        
        if ignoreAlpha {
            return s_rgba.r == c_rgba.r &&
            s_rgba.g == c_rgba.g &&
            s_rgba.b == c_rgba.b
        } else {
            return s_rgba == c_rgba
        }
    }
}
