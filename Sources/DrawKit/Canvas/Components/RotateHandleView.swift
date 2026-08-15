//
//  RotateHandleView.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/14/26.
//

import SwiftUI

struct RotateHandleView: View {
    
    let zoomScale: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.background)
                .strokeBorder(Color.accentColor, lineWidth: 2 / zoomScale)
                .frame(
                    width: 10 / zoomScale,
                    height: 10 / zoomScale
                )
                .shadow(color: .black.opacity(0.2), radius: 2 / zoomScale, y: 1 / zoomScale)
        }
        .frame(
            width: 10 / zoomScale,
            height: 10 / zoomScale
        )
    }
}
