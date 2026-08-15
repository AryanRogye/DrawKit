//
//  EraserShape.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/14/26.
//

import SwiftUI

private enum EraserColor {
    static let right = LinearGradient(
        stops: [
            .init(color: Color(hex: "#C46F75")!, location: 0),
            .init(color: Color(hex: "#C66F79")!, location: 0.5),
            .init(color: Color(hex: "#B17B87")!, location: 1)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let top = LinearGradient(
        stops: [
            .init(
                color: Color(hex: "#E78D9F")!,
                location: 0.0
            ),
            .init(
                color: Color(hex: "#E4879E")!,
                location: 0.3
            ),
            .init(
                color: Color(hex: "#E88B9F")!,
                location: 0.7
            )
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    static let bottom = Color(hex: "#F395AC")!
}

struct EraserShape: View {
    @State private var paddingTop: CGFloat = 17
    @State private var paddingRight: CGFloat = 3
    @State private var cornerRadius: CGFloat = 12
    @State private var bottomRightCornerRadius: CGFloat = 15
    @State private var bottomLeftCornerRadius: CGFloat = 4

#if DEBUG
    let isPopover: Bool = false
#endif

    var body: some View {
        ZStack {
            EraserRightShape(
                paddingTop: paddingTop,
                paddingRight: paddingRight,
                cornerRadius: cornerRadius,
                bottomRightCornerRadius: bottomRightCornerRadius,
                bottomLeftCornerRadius: bottomLeftCornerRadius
            )
            .fill(EraserColor.right)

            EraserTopShape(
                paddingTop: paddingTop,
                paddingRight: paddingRight
            )
            .fill(EraserColor.top)

            EraserBottomShape(
                paddingTop: paddingTop,
                paddingRight: paddingRight,
                cornerRadius: cornerRadius
            )
            .fill(EraserColor.bottom)
        }
        .drawingGroup()
#if DEBUG
        #if os(macOS)
        .popover(isPresented: .constant(isPopover)) {
            VStack {
                Slider(value: $paddingTop, in: 0...100, step: 1) {
                    Text("Padding Top: \(paddingTop)")
                        .frame(width: 160)
                }
                Slider(value: $paddingRight, in: 0...100, step: 1) {
                    Text("Padding Right: \(paddingRight)")
                        .frame(width: 160)
                }
                Slider(value: $cornerRadius, in: 0...100, step: 1) {
                    Text("Corner Radius: \(cornerRadius)")
                        .frame(width: 160)
                }
                Slider(value: $bottomRightCornerRadius, in: 0...100, step: 1) {
                    Text("Bottom Right Radius: \(bottomRightCornerRadius)")
                        .frame(width: 160)
                }
                Slider(value: $bottomLeftCornerRadius, in: 0...100, step: 1) {
                    Text("Bottom Left Radius: \(bottomLeftCornerRadius)")
                        .frame(width: 160)
                }
            }
            .frame(width: 360)
        }
        #elseif os(iOS)
        .overlay(alignment: .bottom) {
            if isPopover {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Padding Top: \(Int(paddingTop))")
                        Slider(value: $paddingTop, in: 0...100, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Padding Right: \(Int(paddingRight))")
                        Slider(value: $paddingRight, in: 0...100, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Corner Radius: \(Int(cornerRadius))")
                        Slider(value: $cornerRadius, in: 0...100, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Bottom Right Radius: \(Int(bottomRightCornerRadius))")
                        Slider(value: $bottomRightCornerRadius, in: 0...100, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Bottom Left Radius: \(Int(bottomLeftCornerRadius))")
                        Slider(value: $bottomLeftCornerRadius, in: 0...100, step: 1)
                    }
                }
                .frame(width: 200)
                .offset(y: 300)
            }
        }

        #endif
#endif
    }
}

struct EraserRightShape: Shape {
    let paddingTop: CGFloat
    let paddingRight: CGFloat
    let cornerRadius: CGFloat
    let bottomRightCornerRadius: CGFloat
    let bottomLeftCornerRadius: CGFloat

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()

        let rightInsetX = rect.maxX - paddingRight
        let bottomLeftCurveX = rightInsetX - (cornerRadius * 2)

        let topRight = CGPoint(
            x: rect.maxX - 0.1,
            y: rect.minY
        )
        let bottomRight = CGPoint(
            x: rect.maxX,
            y: rect.maxY
        )
        let beforeBottomRight = CGPoint(
            x: bottomRight.x,
            y: bottomRight.y - bottomRightCornerRadius
        )
        let afterBottomRight = CGPoint(
            x: bottomRight.x - bottomRightCornerRadius,
            y: bottomRight.y
        )

        let bottomLeft = CGPoint(
            x: rightInsetX,
            y: rect.maxY
        )
        let beforeBottomLeft = CGPoint(
            x: bottomLeftCurveX,
            y: bottomLeft.y
        )
        let afterBottomLeft = CGPoint(
            x: bottomLeftCurveX,
            y: bottomLeft.y - bottomLeftCornerRadius
        )

        let topLeft = CGPoint(
            x: rightInsetX - 0.5,
            y: rect.minY + paddingTop
        )

        path.move(to: topRight)
        path.addLine(to: beforeBottomRight)
        path.addQuadCurve(
            to: afterBottomRight,
            control: bottomRight
        )
        path.addLine(to: beforeBottomLeft)
        path.addQuadCurve(
            to: afterBottomLeft,
            control: bottomLeft
        )
        path.addLine(to: topLeft)
        path.closeSubpath()

        return path
    }
}

struct EraserTopShape: Shape {
    let paddingTop: CGFloat
    let paddingRight: CGFloat

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()

        let bottomY = rect.minY + paddingTop

        let bottomLeft = CGPoint(
            x: rect.minX,
            y: bottomY
        )
        let topLeft = CGPoint(
            x: rect.minX,
            y: rect.minY
        )
        let beforeTopLeft = CGPoint(
            x: rect.minX + paddingRight,
            y: rect.minY
        )
        let topRight = CGPoint(
            x: rect.maxX,
            y: rect.minY
        )
        let bottomRight = CGPoint(
            x: rect.maxX - paddingRight,
            y: bottomY
        )

        path.move(to: bottomLeft)
        path.addLine(to: bottomRight)
        path.addLine(to: topRight)
        path.addLine(to: beforeTopLeft)
        path.addQuadCurve(
            to: bottomLeft,
            control: topLeft
        )
        path.closeSubpath()

        return path
    }
}

struct EraserBottomShape: Shape {
    let paddingTop: CGFloat
    let paddingRight: CGFloat
    let cornerRadius: CGFloat

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()

        let rightInsetX = rect.maxX - paddingRight
        let topY = rect.minY + paddingTop

        let bottomLeft = CGPoint(
            x: rect.minX,
            y: rect.maxY
        )
        let beforeBottomLeft = CGPoint(
            x: bottomLeft.x,
            y: bottomLeft.y - cornerRadius
        )
        let afterBottomLeft = CGPoint(
            x: bottomLeft.x + cornerRadius,
            y: bottomLeft.y
        )

        let bottomRight = CGPoint(
            x: rightInsetX,
            y: rect.maxY
        )
        let beforeBottomRight = CGPoint(
            x: bottomRight.x - cornerRadius,
            y: bottomRight.y
        )
        let afterBottomRight = CGPoint(
            x: bottomRight.x,
            y: bottomRight.y - cornerRadius
        )

        let topLeft = CGPoint(
            x: rect.minX,
            y: topY
        )
        let topRight = CGPoint(
            x: rightInsetX,
            y: topY
        )

        path.move(to: beforeBottomLeft)
        path.addQuadCurve(
            to: afterBottomLeft,
            control: bottomLeft
        )
        path.addLine(to: beforeBottomRight)
        path.addQuadCurve(to: afterBottomRight, control: bottomRight)
        path.addLine(to: topRight)
        path.addLine(to: topLeft)
        path.closeSubpath()

        return path
    }
}

#Preview {
    #if os(macOS)
    ZStack {
        EraserShape()
            .frame(width: 50, height: 100)
    }
    .frame(width: 200, height: 200)
    #elseif os(iOS)
    ZStack {
        EraserShape()
            .frame(width: 100, height: 200)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    #endif
}
