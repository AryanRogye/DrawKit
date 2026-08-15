//
//  PenShape.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/12/26.
//

import SwiftUI

public struct PenShapeStroke: View {
    
    let color: Color
    
    @State private var offset: CGFloat = 8
    @State private var dipOffsetY: CGFloat = 6

    public init(color: Color) {
        self.color = color
    }

    public var body: some View {
        PenOutline(
            dipOffsetY: dipOffsetY,
            offset: offset
        )
        .fill(
            color,
        )
    }
}

public struct PenShape: View {
    
    @State private var offset: CGFloat = 8
    @State private var dipAmount: CGFloat = 11
    @State private var dipOffsetX: CGFloat = 5
    @State private var dipOffsetY: CGFloat = 6
    @State private var predipOffsetX: CGFloat = 10
    @State private var predipOffsetY: CGFloat = 2
    
#if DEBUG
    let isPopover: Bool = false
#endif

    public init() {}
    
    var blackColor: Color {
        .black.mix(with: .white, by: 0.3)
    }
    
    var whiteColor: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .gray.mix(with: .white, by: 0.6), location: 0.0),
                .init(color: .gray.mix(with: .white, by: 0.8), location: 0.3),
                .init(color: .gray.mix(with: .white, by: 1), location: 1.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    public var body: some View {
        ZStack {
            PenTopShape(
                offset: offset
            )
            .fill(blackColor)
            PenMiddleShape(
                offset: offset,
                dipAmount: dipAmount,
                predipOffsetX: predipOffsetX,
                predipOffsetY: predipOffsetY,
                dipOffsetX: dipOffsetX,
                dipOffsetY: dipOffsetY
            )
            .fill(whiteColor)
            PenShapeBottom(
                dipAmount: dipAmount,
                predipOffsetX: predipOffsetX,
                predipOffsetY: predipOffsetY,
                dipOffsetX: dipOffsetX,
                dipOffsetY: dipOffsetY
            )
            .fill(blackColor)
            
            PenOutline(
                dipOffsetY: dipOffsetY,
                offset: offset
            )
            .stroke(
                blackColor,
                style: .init(lineWidth: 0.1)
            )
        }
        .drawingGroup()
#if DEBUG
        .popover(isPresented: .constant(isPopover)) {
            VStack {
                Slider(value: $offset, in: 0...100, step: 1) {
                    Text("Offset: \(offset)")
                        .frame(width: 100)
                }
                Slider(value: $dipAmount, in: 0...100, step: 1) {
                    Text("Dip Amount: \(dipAmount)")
                        .frame(width: 100)
                }
                Slider(value: $dipOffsetX, in: 0...100, step: 1) {
                    Text("Dip Offset X: \(dipOffsetX)")
                        .frame(width: 100)
                }
                Slider(value: $dipOffsetY, in: 0...100, step: 1) {
                    Text("Dip Offset Y: \(dipOffsetY)")
                        .frame(width: 100)
                }
                Slider(value: $predipOffsetX, in: 0...100, step: 1) {
                    Text("PreDip X: \(predipOffsetX)")
                        .frame(width: 100)
                }
                Slider(value: $predipOffsetY, in: 0...100, step: 1) {
                    Text("PreDip Y: \(predipOffsetY)")
                        .frame(width: 100)
                }
            }.frame(width: 300)
        }
#endif
    }
}

struct PenOutline: Shape {
    
    let dipOffsetY: CGFloat
    let offset: CGFloat
    
    nonisolated func path(in rect: CGRect) -> Path {
        let bottomLeftX = rect.minX
        let bottomLeftY = rect.maxY
        
        let midLeftX = rect.minX
        let midLeftY = rect.midY + dipOffsetY
        
        let midRightX = rect.maxX
        let midRightY = rect.midY + dipOffsetY
        
        let bottomRightX = rect.maxX
        let bottomRightY = rect.maxY
        
        let centerLeftX = rect.midX - offset
        let centerLeftY = rect.minY + offset
        
        let centerRightX = rect.midX + offset
        let centerRightY = rect.minY + offset
        
        var path = Path()
        
        path.move(
            to: .init(
                x: bottomLeftX,
                y: bottomLeftY
            )
        )
        
        path.addLine(
            to: .init(
                x: midLeftX,
                y: midLeftY
            )
        )
        
        path.addLine(
            to: .init(
                x: centerLeftX,
                y: centerLeftY
            )
        )
        
        path.addQuadCurve(
            to: .init(
                x: rect.midX,
                y: rect.minY
            ),
            control: .init(
                x: rect.midX - (offset / 2),
                y: rect.minY
            )
        )
        
        path.addQuadCurve(
            to: .init(
                x: centerRightX,
                y: centerRightY
            ),
            control: .init(
                x: rect.midX + (offset / 2),
                y: rect.minY
            )
        )
        
        path.addLine(
            to: .init(
                x: centerRightX,
                y: centerRightY
            )
        )
        
        path.addLine(
            to: .init(
                x: midRightX,
                y: midRightY
            )
        )
        
        
        path.addLine(
            to: .init(
                x: bottomRightX,
                y: bottomRightY
            )
        )
        
        path.closeSubpath()

        return path
    }
}

struct PenTopShape: Shape {
    
    let offset: CGFloat
    
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let centerLeftX = rect.midX - offset
        let centerLeftY = rect.minY + offset
        
        let centerRightX = rect.midX + offset
        let centerRightY = rect.minY + offset

        path.move(
            to: .init(
                x: centerLeftX,
                y: centerLeftY
            )
        )
        
        path.addQuadCurve(
            to: .init(
                x: rect.midX,
                y: rect.minY
            ),
            control: .init(
                x: rect.midX - (offset / 2),
                y: rect.minY
            )
        )

        path.addQuadCurve(
            to: .init(
                x: centerRightX,
                y: centerRightY
            ),
            control: .init(
                x: rect.midX + (offset / 2),
                y: rect.minY
            )
        )
        
        return path
    }
}

struct PenMiddleShape: Shape {
    
    let offset: CGFloat
    let dipAmount: CGFloat
    let predipOffsetX: CGFloat
    let predipOffsetY: CGFloat
    let dipOffsetX: CGFloat
    let dipOffsetY: CGFloat
    
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midLeftX = rect.minX
        let midLeftY = rect.midY + dipOffsetY
        
        let midRightX = rect.maxX
        let midRightY = rect.midY + dipOffsetY
        
        let centerLeftX = rect.midX - offset
        let centerLeftY = rect.minY + offset
        
        let centerRightX = rect.midX + offset
        let centerRightY = rect.minY + offset
        
        let middleDipStartX = rect.midX - dipOffsetX
        let middleDipStartY = rect.midY + dipOffsetY
        
        let middleDipEndX = rect.midX + dipOffsetX
        let middleDipEndY = rect.midY + dipOffsetY
        
        let middlePreDipStartX = middleDipStartX - predipOffsetX
        let middlePreDipStartY = middleDipStartY - predipOffsetY
        
        let middlePreDipEndX = middleDipEndX + predipOffsetX
        let middlePreDipEndY = middleDipStartY - predipOffsetY
        
        let middleDipX = rect.midX
        let middleDipY = rect.midY + dipAmount
        let middleDipLeftControlX = middleDipX - (dipOffsetX / 3)
        let middleDipRightControlX = middleDipX + (dipOffsetX / 3)

        // middle left start
        path.move(
            to: .init(
                x: midLeftX,
                y: midLeftY
            )
        )
        
        // goes up to the left center with offset
        path.addLine(
            to: .init(
                x: centerLeftX,
                y: centerLeftY
            )
        )
        
        // goes to the right center with offset
        path.addLine(
            to: .init(
                x: centerRightX,
                y: centerRightY
            )
        )

        // goes back down to the bottom right center
        path.addLine(
            to: .init(
                x: midRightX,
                y: midRightY
            )
        )
        
        // goes to the predip end area
        path.addLine(
            to: .init(
                x: middlePreDipEndX,
                y: middlePreDipEndY
            )
        )
        
        // curve down toward the center from the right
        path.addCurve(
            to: .init(
                x: middleDipX,
                y: middleDipY
            ),
            control1: .init(
                x: middleDipEndX,
                y: middleDipEndY
            ),
            control2: .init(
                x: middleDipRightControlX,
                y: middleDipY
            )
        )
        
        // curve back up to the left predip
        path.addCurve(
            to: .init(
                x: middlePreDipStartX,
                y: middlePreDipStartY
            ),
            control1: .init(
                x: middleDipLeftControlX,
                y: middleDipY
            ),
            control2: .init(
                x: middleDipStartX,
                y: middleDipStartY
            )
        )

        path.closeSubpath()

        return path
    }
}

struct PenShapeBottom: Shape {
    
    let dipAmount: CGFloat
    let predipOffsetX: CGFloat
    let predipOffsetY: CGFloat
    let dipOffsetX: CGFloat
    let dipOffsetY: CGFloat

    /**
     * (0,0) ─────────────────── (300,0)
     * │
     * │
     * │
     * │
     * (0,200) ──────────────── (300,200)
     */
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let bottomLeftX = rect.minX
        let bottomLeftY = rect.maxY
        
        let midLeftX = rect.minX
        let midLeftY = rect.midY + dipOffsetY
        
        let middleDipStartX = rect.midX - dipOffsetX
        let middleDipStartY = rect.midY + dipOffsetY
        
        let middleDipEndX = rect.midX + dipOffsetX
        let middleDipEndY = rect.midY + dipOffsetY
        
        let middlePreDipStartX = middleDipStartX - predipOffsetX
        let middlePreDipStartY = middleDipStartY - predipOffsetY
        
        let middlePreDipEndX = middleDipEndX + predipOffsetX
        let middlePreDipEndY = middleDipStartY - predipOffsetY
        

        let middleDipX = rect.midX
        let middleDipY = rect.midY + dipAmount
        let middleDipLeftControlX = middleDipX - (dipOffsetX / 3)
        let middleDipRightControlX = middleDipX + (dipOffsetX / 3)
        
        let midRightX = rect.maxX
        let midRightY = rect.midY + dipOffsetY

        let bottomRightX = rect.maxX
        let bottomRightY = rect.maxY
        
        // bottom left
        path.move(
            to: .init(
                x: bottomLeftX,
                y: bottomLeftY
            )
        )
        
        // mid left
        path.addLine(
            to: .init(
                x: midLeftX,
                y: midLeftY
            )
        )
        
        // start of predip
        path.addLine(
            to: .init(
                x: middlePreDipStartX,
                y: middlePreDipStartY
            )
        )
        
        // curve down toward the center from the left
        path.addCurve(
            to: .init(
                x: middleDipX,
                y: middleDipY
            ),
            control1: .init(
                x: middleDipStartX,
                y: middleDipStartY
            ),
            control2: .init(
                x: middleDipLeftControlX,
                y: middleDipY
            )
        )
        
        // curve back up to the right predip
        path.addCurve(
            to: .init(
                x: middlePreDipEndX,
                y: middlePreDipEndY
            ),
            control1: .init(
                x: middleDipRightControlX,
                y: middleDipY
            ),
            control2: .init(
                x: middleDipEndX,
                y: middleDipEndY
            )
        )
        
        // mid right
        path.addLine(
            to: .init(
                x: midRightX,
                y: midRightY
            )
        )
        
        // bottom right
        path.addLine(
            to: .init(
                x: bottomRightX,
                y: bottomRightY
            )
        )
        path.closeSubpath()

        return path
    }
}
