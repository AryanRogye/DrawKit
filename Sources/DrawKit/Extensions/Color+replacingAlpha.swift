//
//  Color+replacingAlpha.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/13/26.
//

import SwiftUI

extension Color {
    func replacingAlpha(with alpha: Double) -> Color {
        Color(SystemColor(self).withAlphaComponent(alpha))
    }
}
