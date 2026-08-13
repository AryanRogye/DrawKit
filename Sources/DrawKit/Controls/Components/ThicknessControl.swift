//
//  ThicknessControl.swift
//  DrawKit
//
//  Created by Aryan Rogye on 8/13/26.
//

import SwiftUI

/// A compact, discrete control for choosing a drawing stroke thickness.
public struct ThicknessControl: View {

    @Binding private var value: CGFloat

    private let values: [CGFloat]

    @Environment(\.colorScheme) private var colorScheme

    /// Creates a thickness control with six commonly useful stroke widths.
    ///
    /// The supplied value is displayed at the nearest available stop and is
    /// replaced by the exact stop value when the control is used.
    public init(
        value: Binding<CGFloat>,
        values: [CGFloat] = [1, 2, 4, 6, 8, 12]
    ) {
        self._value = value
        self.values = values.isEmpty ? [1] : values.sorted()
    }

    public var body: some View {
        GeometryReader { proxy in
            let metrics = Metrics(size: proxy.size, stopCount: values.count)

            ZStack {
                Capsule()
                    .fill(trackColor)
                    .frame(
                        width: metrics.lastStopX - metrics.firstStopX,
                        height: 2
                    )
                    .position(
                        x: (metrics.firstStopX + metrics.lastStopX) / 2,
                        y: metrics.centerY
                    )

                ForEach(values.indices, id: \.self) { index in
                    let isSelected = index == selectedIndex
                    let isFilled = index <= selectedIndex

                    Circle()
                        .fill(isFilled ? filledStopColor : emptyStopColor)
                        .frame(
                            width: isSelected ? 26 : 15,
                            height: isSelected ? 26 : 15
                        )
                        .position(
                            x: metrics.xPosition(for: index),
                            y: metrics.centerY
                        )
                        .animation(
                            .spring(response: 0.24, dampingFraction: 0.86),
                            value: selectedIndex
                        )
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        selectStop(closestTo: gesture.location.x, metrics: metrics)
                    }
            )
        }
    }

    private var filledStopColor: Color {
        colorScheme == .dark ? Color(white: 0.72) : Color(white: 0.46)
    }

    private var emptyStopColor: Color {
        colorScheme == .dark ? Color(white: 0.30) : Color(white: 0.90)
    }

    private var trackColor: Color {
        colorScheme == .dark ? Color(white: 0.24) : Color(white: 0.88)
    }

    private var selectedIndex: Int {
        values.indices.min { left, right in
            abs(values[left] - value) < abs(values[right] - value)
        } ?? 0
    }

    private var formattedValue: String {
        let selectedValue = values[selectedIndex]
        return Double(selectedValue).formatted(
            .number.precision(.fractionLength(0...1))
        )
    }

    private func selectStop(closestTo xPosition: CGFloat, metrics: Metrics) {
        let index = values.indices.min { left, right in
            abs(metrics.xPosition(for: left) - xPosition)
                < abs(metrics.xPosition(for: right) - xPosition)
        } ?? 0

        select(index: index)
    }

    private func select(index: Int) {
        guard values.indices.contains(index), value != values[index] else { return }

        withAnimation(
            .spring(response: 0.24, dampingFraction: 0.86)
        ) {
            value = values[index]
        }
    }
}

private extension ThicknessControl {

    struct Metrics {
        let size: CGSize
        let stopCount: Int

        var centerY: CGFloat { size.height / 2 }
        var endCapInset: CGFloat { 3 }
        var stopInset: CGFloat { 13 }
        var firstStopX: CGFloat { stopInset }
        var lastStopX: CGFloat { size.width - stopInset }

        func xPosition(for index: Int) -> CGFloat {
            guard stopCount > 1 else { return size.width / 2 }

            let progress = CGFloat(index) / CGFloat(stopCount - 1)
            return firstStopX + ((lastStopX - firstStopX) * progress)
        }
    }
}

#Preview("Thickness Control") {
    @Previewable @State var thickness: CGFloat = 2

    ThicknessControl(value: $thickness)
        .frame(width: 150, height: 90)
        .padding()
}
