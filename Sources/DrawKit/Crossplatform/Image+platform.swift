//
//  Image+platform.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/13/26.
//

import SwiftUI

extension Image {
    init(image: SystemImage) {
        #if os(macOS)
        self.init(nsImage: image)
        #elseif os(iOS)
        self.init(uiImage: image)
        #endif
    }
}
