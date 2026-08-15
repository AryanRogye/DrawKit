//
//  Haptics.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/14/26.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

enum Haptics {
    static func performDetentHaptic() {
        #if os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(
            .alignment,
            performanceTime: .now
        )
        #elseif os(iOS)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }
}
