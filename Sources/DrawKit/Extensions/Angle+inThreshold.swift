//
//  Angle+inThreshold.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/14/26.
//

import SwiftUI

extension Angle {
    public func inThreshold(
        of angle: Angle,
        threshold: Double
    ) -> Bool {
        var diff = (angle.degrees - degrees)
            .truncatingRemainder(dividingBy: 360)
        
        if diff > 180 { diff -= 360 }
        if diff < -180 { diff += 360 }
        
        return abs(diff) <= threshold
    }
}
