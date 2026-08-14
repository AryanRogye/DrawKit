//
//  Color+alpha.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

extension Color {
    var alpha: Double {
        if let rgba = self.rgba {
            return Double(rgba.a)
        }
        return 1
    }
}
