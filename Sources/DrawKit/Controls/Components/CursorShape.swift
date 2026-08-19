//
//  CursorShape.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/18/26.
//

import SwiftUI

/// A projected, dimensional cursor with a pencil-like eraser.
///
/// The cursor is constructed on a centered local axis and then rotated into
/// place. Its depth is a true projected copy of that front geometry, so every
/// visible side shares one projection vector.
public struct CursorShape: View {
    private let color: Color
    private let showsDebugControls: Bool

    @State private var angle: CGFloat = 46.152
    @State private var arrowLength: CGFloat = 1.00
    @State private var headLength: CGFloat = 0.551
    @State private var headWidth: CGFloat = 0.610
    @State private var shaftWidth: CGFloat = 0.135
    @State private var notchRoundness: CGFloat = 0.050
    @State private var wingRoundness: CGFloat = 0.090
    @State private var tipRoundness: CGFloat = 0.060
    @State private var ferruleLength: CGFloat = 0.108
    @State private var eraserLength: CGFloat = 0.122
    @State private var projectionX: CGFloat = 0.044
    @State private var projectionY: CGFloat = 0.038
    @State private var sideDarkness: CGFloat = 0.20
    @State private var highlightWidth: CGFloat = 1.517
    @State private var highlightOpacity: CGFloat = 1
    @State private var highlightBlur: CGFloat = 1.452

    public init(
        color: Color = .blue,
        showsDebugControls: Bool = false
    ) {
        self.color = color
        self.showsDebugControls = showsDebugControls
    }

    public var body: some View {
        let geometry = CursorGeometry(
            angle: angle,
            arrowLength: arrowLength,
            headLength: headLength,
            headWidth: headWidth,
            shaftWidth: shaftWidth,
            notchRoundness: notchRoundness,
            wingRoundness: wingRoundness,
            tipRoundness: tipRoundness,
            ferruleLength: ferruleLength,
            eraserLength: eraserLength
        )
        let projection = NormalizedPoint(x: projectionX, y: projectionY)

        ZStack {
            CursorProjectionLayers(
                geometry: geometry,
                projection: projection,
                color: color,
                sideDarkness: sideDarkness
            )

            CursorBodyShape(geometry: geometry)
                .fill(bodyGradient)

            CursorFerruleShape(geometry: geometry)
                .fill(ferruleGradient)

            CursorEraserShape(geometry: geometry)
                .fill(eraserGradient)

            CursorHighlightShape(geometry: geometry)
                .stroke(
                    color.mix(with: .white, by: 0.92).opacity(highlightOpacity),
                    style: StrokeStyle(
                        lineWidth: highlightWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .blur(radius: highlightBlur)

            CursorEraserHighlightShape(geometry: geometry)
                .fill(.white.opacity(0.5))
                .blur(radius: 1.2)
                .mask(CursorEraserShape(geometry: geometry))

            CursorBodyShape(geometry: geometry)
                .stroke(
                    color.mix(with: .black, by: 0.5).opacity(0.48),
                    style: StrokeStyle(lineWidth: 0.6, lineJoin: .round)
                )

            CursorFerruleShape(geometry: geometry)
                .stroke(.black.opacity(0.42), lineWidth: 0.55)

            CursorEraserShape(geometry: geometry)
                .stroke(.black.opacity(0.24), lineWidth: 0.55)
        }
        .drawingGroup()
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
#if DEBUG
        #if os(macOS)
        .popover(isPresented: .constant(showsDebugControls)) {
            debugControls
        }
        #elseif os(iOS)
        .overlay(alignment: .bottom) {
            if showsDebugControls {
                debugControls
                    .offset(y: 380)
            }
        }
        #endif
#endif
    }

    private var bodyGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: color.mix(with: .white, by: 0.34), location: 0),
                .init(color: color.mix(with: .white, by: 0.14), location: 0.28),
                .init(color: color, location: 0.64),
                .init(color: color.mix(with: .black, by: 0.12), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var ferruleGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(white: 0.48), location: 0),
                .init(color: Color(white: 0.16), location: 0.45),
                .init(color: Color(white: 0.32), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var eraserGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .white, location: 0),
                .init(color: Color(white: 0.94), location: 0.52),
                .init(color: Color(white: 0.75), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

#if DEBUG
    private var debugControls: some View {
        CursorDebugControls(
            angle: $angle,
            arrowLength: $arrowLength,
            headLength: $headLength,
            headWidth: $headWidth,
            shaftWidth: $shaftWidth,
            notchRoundness: $notchRoundness,
            wingRoundness: $wingRoundness,
            tipRoundness: $tipRoundness,
            ferruleLength: $ferruleLength,
            eraserLength: $eraserLength,
            projectionX: $projectionX,
            projectionY: $projectionY,
            sideDarkness: $sideDarkness,
            highlightWidth: $highlightWidth,
            highlightOpacity: $highlightOpacity,
            highlightBlur: $highlightBlur
        )
    }
#endif
}

private struct NormalizedPoint: Sendable {
    let x: CGFloat
    let y: CGFloat

    static let zero = Self(x: 0, y: 0)

    static func + (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (lhs: Self, rhs: CGFloat) -> Self {
        Self(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    var length: CGFloat {
        hypot(x, y)
    }

    func point(toward destination: Self, distance: CGFloat) -> Self {
        let delta = destination - self
        guard delta.length > 0 else { return self }
        return self + delta * (min(distance, delta.length / 2) / delta.length)
    }
}

private struct CursorGeometry: Sendable {
    let angle: CGFloat
    let arrowLength: CGFloat
    let headLength: CGFloat
    let headWidth: CGFloat
    let shaftWidth: CGFloat
    let notchRoundness: CGFloat
    let wingRoundness: CGFloat
    let tipRoundness: CGFloat
    let ferruleLength: CGFloat
    let eraserLength: CGFloat

    private let origin = NormalizedPoint(x: 0.07, y: 0.93)

    private var direction: NormalizedPoint {
        let radians = -angle * .pi / 180
        return NormalizedPoint(x: cos(radians), y: sin(radians))
    }

    private var normal: NormalizedPoint {
        NormalizedPoint(x: -direction.y, y: direction.x)
    }

    var bodyStart: CGFloat {
        eraserLength + ferruleLength
    }

    var headStart: CGFloat {
        max(bodyStart + 0.12, arrowLength - headLength)
    }

    var shaftHalfWidth: CGFloat {
        shaftWidth / 2
    }

    var headHalfWidth: CGFloat {
        headWidth / 2
    }

    func point(along: CGFloat, lateral: CGFloat) -> NormalizedPoint {
        origin + direction * along + normal * lateral
    }

    func bodyVertices() -> [(point: NormalizedPoint, radius: CGFloat)] {
        [
            (point(along: bodyStart, lateral: -shaftHalfWidth), 0),
            (point(along: headStart, lateral: -shaftHalfWidth), notchRoundness),
            (point(along: headStart, lateral: -headHalfWidth), wingRoundness),
            (point(along: arrowLength, lateral: 0), tipRoundness),
            (point(along: headStart, lateral: headHalfWidth), wingRoundness),
            (point(along: headStart, lateral: shaftHalfWidth), notchRoundness),
            (point(along: bodyStart, lateral: shaftHalfWidth), 0)
        ]
    }

    func point(_ normalizedPoint: NormalizedPoint, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * normalizedPoint.x,
            y: rect.minY + rect.height * normalizedPoint.y
        )
    }
}

private struct CursorProjectionLayers: View {
    let geometry: CursorGeometry
    let projection: NormalizedPoint
    let color: Color
    let sideDarkness: CGFloat

    var body: some View {
        ZStack {
            ForEach(ProjectionLayer.all) { layer in
                let layerOffset = projection * layer.progress
                let darkness = sideDarkness * (0.72 + 0.28 * layer.progress)

                CursorEraserShape(
                    geometry: geometry,
                    projection: layerOffset
                )
                .fill(Color(white: 0.68 - 0.2 * layer.progress))

                CursorFerruleShape(
                    geometry: geometry,
                    projection: layerOffset
                )
                .fill(Color(white: 0.08 + 0.08 * (1 - layer.progress)))

                CursorBodyShape(
                    geometry: geometry,
                    projection: layerOffset
                )
                .fill(color.mix(with: .black, by: darkness))
            }
        }
    }
}

private struct ProjectionLayer: Identifiable, Sendable {
    let id: Int
    let progress: CGFloat

    static let all: [Self] = (1...14).reversed().map { layer in
        Self(id: layer, progress: CGFloat(layer) / 14)
    }
}

private struct CursorBodyShape: Shape {
    let geometry: CursorGeometry
    var projection: NormalizedPoint = .zero

    nonisolated func path(in rect: CGRect) -> Path {
        roundedPath(
            vertices: geometry.bodyVertices(),
            geometry: geometry,
            projection: projection,
            rect: rect
        )
    }
}

private struct CursorFerruleShape: Shape {
    let geometry: CursorGeometry
    var projection: NormalizedPoint = .zero

    nonisolated func path(in rect: CGRect) -> Path {
        let start = geometry.eraserLength
        let end = geometry.bodyStart
        let halfWidth = geometry.shaftHalfWidth
        let vertices = [
            geometry.point(along: start, lateral: -halfWidth),
            geometry.point(along: end, lateral: -halfWidth),
            geometry.point(along: end, lateral: halfWidth),
            geometry.point(along: start, lateral: halfWidth)
        ]

        return polygonPath(
            vertices: vertices,
            geometry: geometry,
            projection: projection,
            rect: rect
        )
    }
}

private struct CursorEraserShape: Shape {
    let geometry: CursorGeometry
    var projection: NormalizedPoint = .zero

    nonisolated func path(in rect: CGRect) -> Path {
        let end = geometry.eraserLength
        let halfWidth = geometry.shaftHalfWidth
        let capInset = min(0.035, end * 0.3)
        let projected: (NormalizedPoint) -> CGPoint = { normalizedPoint in
            geometry.point(normalizedPoint + projection, in: rect)
        }

        var path = Path()
        path.move(to: projected(geometry.point(along: end, lateral: -halfWidth)))
        path.addLine(to: projected(geometry.point(along: capInset, lateral: -halfWidth)))
        path.addQuadCurve(
            to: projected(geometry.point(along: 0, lateral: 0)),
            control: projected(geometry.point(along: 0, lateral: -halfWidth))
        )
        path.addQuadCurve(
            to: projected(geometry.point(along: capInset, lateral: halfWidth)),
            control: projected(geometry.point(along: 0, lateral: halfWidth))
        )
        path.addLine(to: projected(geometry.point(along: end, lateral: halfWidth)))
        path.closeSubpath()
        return path
    }
}

private struct CursorHighlightShape: Shape {
    let geometry: CursorGeometry

    nonisolated func path(in rect: CGRect) -> Path {
        let shaftInset = geometry.shaftHalfWidth * 0.56
        let headInset = geometry.headHalfWidth * 0.78
        var path = Path()

        path.move(
            to: geometry.point(
                geometry.point(
                    along: geometry.bodyStart + 0.025,
                    lateral: -shaftInset
                ),
                in: rect
            )
        )
        path.addLine(
            to: geometry.point(
                geometry.point(
                    along: geometry.headStart - 0.035,
                    lateral: -shaftInset
                ),
                in: rect
            )
        )

        path.move(
            to: geometry.point(
                geometry.point(
                    along: geometry.headStart + 0.025,
                    lateral: -headInset
                ),
                in: rect
            )
        )
        path.addQuadCurve(
            to: geometry.point(
                geometry.point(
                    along: geometry.arrowLength - 0.105,
                    lateral: -0.028
                ),
                in: rect
            ),
            control: geometry.point(
                geometry.point(
                    along: geometry.headStart + geometry.headLength * 0.58,
                    lateral: -geometry.headHalfWidth * 0.58
                ),
                in: rect
            )
        )
        return path
    }
}

private struct CursorEraserHighlightShape: Shape {
    let geometry: CursorGeometry

    nonisolated func path(in rect: CGRect) -> Path {
        let center = geometry.point(
            along: geometry.eraserLength * 0.42,
            lateral: -geometry.shaftHalfWidth * 0.32
        )
        let point = geometry.point(center, in: rect)
        var path = Path()
        path.addEllipse(
            in: CGRect(
                x: point.x - rect.width * 0.045,
                y: point.y - rect.height * 0.028,
                width: rect.width * 0.09,
                height: rect.height * 0.056
            )
        )
        return path
    }
}

private func roundedPath(
    vertices: [(point: NormalizedPoint, radius: CGFloat)],
    geometry: CursorGeometry,
    projection: NormalizedPoint,
    rect: CGRect
) -> Path {
    guard vertices.count > 2 else { return Path() }

    func projected(_ point: NormalizedPoint) -> CGPoint {
        geometry.point(point + projection, in: rect)
    }

    var path = Path()

    for index in vertices.indices {
        let previousIndex = index == vertices.startIndex
            ? vertices.index(before: vertices.endIndex)
            : vertices.index(before: index)
        let nextIndex = vertices.index(after: index) == vertices.endIndex
            ? vertices.startIndex
            : vertices.index(after: index)
        let vertex = vertices[index]
        let before = vertex.point.point(
            toward: vertices[previousIndex].point,
            distance: vertex.radius
        )
        let after = vertex.point.point(
            toward: vertices[nextIndex].point,
            distance: vertex.radius
        )

        if index == vertices.startIndex {
            path.move(to: projected(before))
        } else {
            path.addLine(to: projected(before))
        }

        if vertex.radius > 0 {
            path.addQuadCurve(
                to: projected(after),
                control: projected(vertex.point)
            )
        } else {
            path.addLine(to: projected(vertex.point))
        }
    }

    path.closeSubpath()
    return path
}

private func polygonPath(
    vertices: [NormalizedPoint],
    geometry: CursorGeometry,
    projection: NormalizedPoint,
    rect: CGRect
) -> Path {
    guard let first = vertices.first else { return Path() }

    var path = Path()
    path.move(to: geometry.point(first + projection, in: rect))

    for vertex in vertices.dropFirst() {
        path.addLine(to: geometry.point(vertex + projection, in: rect))
    }

    path.closeSubpath()
    return path
}

#if DEBUG
private struct CursorDebugControls: View {
    @Binding var angle: CGFloat
    @Binding var arrowLength: CGFloat
    @Binding var headLength: CGFloat
    @Binding var headWidth: CGFloat
    @Binding var shaftWidth: CGFloat
    @Binding var notchRoundness: CGFloat
    @Binding var wingRoundness: CGFloat
    @Binding var tipRoundness: CGFloat
    @Binding var ferruleLength: CGFloat
    @Binding var eraserLength: CGFloat
    @Binding var projectionX: CGFloat
    @Binding var projectionY: CGFloat
    @Binding var sideDarkness: CGFloat
    @Binding var highlightWidth: CGFloat
    @Binding var highlightOpacity: CGFloat
    @Binding var highlightBlur: CGFloat

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CursorDebugSection(title: "Construction") {
                    CursorDebugSlider(title: "Angle", value: $angle, range: 35...55)
                    CursorDebugSlider(title: "Arrow length", value: $arrowLength, range: 0.95...1.2)
                    CursorDebugSlider(title: "Head length", value: $headLength, range: 0.34...0.6)
                    CursorDebugSlider(title: "Head width", value: $headWidth, range: 0.44...0.72)
                    CursorDebugSlider(title: "Shaft width", value: $shaftWidth, range: 0.08...0.19)
                }

                CursorDebugSection(title: "Corners and pencil") {
                    CursorDebugSlider(title: "Notch radius", value: $notchRoundness, range: 0...0.05)
                    CursorDebugSlider(title: "Wing radius", value: $wingRoundness, range: 0...0.09)
                    CursorDebugSlider(title: "Tip radius", value: $tipRoundness, range: 0...0.1)
                    CursorDebugSlider(title: "Ferrule length", value: $ferruleLength, range: 0.035...0.13)
                    CursorDebugSlider(title: "Eraser length", value: $eraserLength, range: 0.08...0.23)
                }

                CursorDebugSection(title: "Projection and light") {
                    CursorDebugSlider(title: "Projection X", value: $projectionX, range: -0.02...0.07)
                    CursorDebugSlider(title: "Projection Y", value: $projectionY, range: -0.02...0.07)
                    CursorDebugSlider(title: "Side darkness", value: $sideDarkness, range: 0.2...0.8)
                    CursorDebugSlider(title: "Highlight width", value: $highlightWidth, range: 0...6)
                    CursorDebugSlider(title: "Highlight opacity", value: $highlightOpacity, range: 0...1)
                    CursorDebugSlider(title: "Highlight blur", value: $highlightBlur, range: 0...4)
                }

                Button(action: reset) {
                    Text(verbatim: "Reset cursor values")
                }
            }
            .padding()
        }
        .frame(width: 360, height: 620)
    }

    private func reset() {
        angle = 45
        arrowLength = 1.13
        headLength = 0.48
        headWidth = 0.62
        shaftWidth = 0.125
        notchRoundness = 0.018
        wingRoundness = 0.045
        tipRoundness = 0.055
        ferruleLength = 0.075
        eraserLength = 0.15
        projectionX = 0.022
        projectionY = 0.028
        sideDarkness = 0.52
        highlightWidth = 2.2
        highlightOpacity = 0.72
        highlightBlur = 1
    }
}

private struct CursorDebugSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: title)
                .font(.headline)
            content
        }
    }
}

private struct CursorDebugSlider: View {
    let title: String
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: "\(title): \(formattedValue)")
                .font(.caption.monospacedDigit())
            Slider(value: $value, in: range)
        }
    }

    private var formattedValue: String {
        Double(value).formatted(.number.precision(.fractionLength(3)))
    }
}
#endif
