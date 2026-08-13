//
//  View+if.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func viewFor<MacOSView: View, iOSView: View>(
        macOSTransform: (Self) -> MacOSView,
        iOSTransform: (Self) -> iOSView
    ) -> some View {
        #if os(macOS)
        macOSTransform(self)
        #elseif os(iOS)
        iOSTransform(self)
        #endif
    }
}

public extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
