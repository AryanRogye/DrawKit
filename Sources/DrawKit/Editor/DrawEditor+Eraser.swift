//
//  DrawEditor+Eraser.swift
//  DrawKit
//
//  Created by OpenAI on 8/15/26.
//

import CoreGraphics
import Foundation

extension DrawEditor {
    func erasePenStrokes(
        from start: CGPoint,
        to end: CGPoint,
        width: CGFloat
    ) {
        let eraserRadius = max(width, 0) / 2

        items = items.flatMap { item in
            guard case .pen(let stroke) = item else {
                return [item]
            }

            return stroke
                .erasing(from: start, to: end, eraserRadius: eraserRadius)
                .map(MarkupItems.pen)
        }
    }
}

private extension PenStroke {
    func erasing(
        from eraserStart: CGPoint,
        to eraserEnd: CGPoint,
        eraserRadius: CGFloat
    ) -> [PenStroke] {
        let effectiveRadius = eraserRadius + max(lineWidth, 0) / 2

        guard points.count > 1 else {
            guard let point = points.first,
                  point.distanceSquared(toSegmentFrom: eraserStart, to: eraserEnd)
                    <= effectiveRadius * effectiveRadius else {
                return [self]
            }
            return []
        }

        var fragmentPoints: [[CGPoint]] = []
        var currentFragment: [CGPoint] = []
        var didErase = false

        func finishCurrentFragment() {
            guard currentFragment.count > 1 else {
                currentFragment.removeAll(keepingCapacity: true)
                return
            }

            fragmentPoints.append(currentFragment)
            currentFragment.removeAll(keepingCapacity: true)
        }

        for (segmentStart, segmentEnd) in zip(points, points.dropFirst()) {
            let retainedIntervals = SegmentClipper.retainedIntervals(
                from: segmentStart,
                to: segmentEnd,
                outsideCapsuleFrom: eraserStart,
                to: eraserEnd,
                radius: effectiveRadius
            )

            if !SegmentClipper.coversEntireSegment(retainedIntervals) {
                didErase = true
            }

            guard !retainedIntervals.isEmpty else {
                finishCurrentFragment()
                continue
            }

            for interval in retainedIntervals {
                let retainedStart = segmentStart.interpolated(
                    to: segmentEnd,
                    progress: interval.lowerBound
                )
                let retainedEnd = segmentStart.interpolated(
                    to: segmentEnd,
                    progress: interval.upperBound
                )

                if let lastPoint = currentFragment.last,
                   lastPoint.isApproximatelyEqual(to: retainedStart) {
                    if !lastPoint.isApproximatelyEqual(to: retainedEnd) {
                        currentFragment.append(retainedEnd)
                    }
                } else {
                    finishCurrentFragment()
                    currentFragment = [retainedStart, retainedEnd]
                }

                if interval.upperBound < 1 - SegmentClipper.tolerance {
                    finishCurrentFragment()
                }
            }
        }

        finishCurrentFragment()

        guard didErase else { return [self] }

        return fragmentPoints.enumerated().map { index, points in
            PenStroke(
                id: index == 0 ? id : UUID(),
                points: points,
                color: color,
                lineWidth: lineWidth
            )
        }
    }
}

private enum SegmentClipper {
    static let tolerance: CGFloat = 0.000_001

    static func retainedIntervals(
        from segmentStart: CGPoint,
        to segmentEnd: CGPoint,
        outsideCapsuleFrom capsuleStart: CGPoint,
        to capsuleEnd: CGPoint,
        radius: CGFloat
    ) -> [ClosedRange<CGFloat>] {
        var boundaries: [CGFloat] = [0, 1]
        let segmentVector = segmentEnd - segmentStart
        let capsuleVector = capsuleEnd - capsuleStart
        let capsuleLengthSquared = capsuleVector.lengthSquared

        appendCircleIntersections(
            center: capsuleStart,
            radius: radius,
            segmentStart: segmentStart,
            segmentVector: segmentVector,
            to: &boundaries
        )
        appendCircleIntersections(
            center: capsuleEnd,
            radius: radius,
            segmentStart: segmentStart,
            segmentVector: segmentVector,
            to: &boundaries
        )

        if capsuleLengthSquared > tolerance {
            let capsuleLength = sqrt(capsuleLengthSquared)
            let initialCross = (segmentStart - capsuleStart).cross(capsuleVector)
            let crossDelta = segmentVector.cross(capsuleVector)

            if abs(crossDelta) > tolerance {
                appendBoundary(
                    (radius * capsuleLength - initialCross) / crossDelta,
                    to: &boundaries
                )
                appendBoundary(
                    (-radius * capsuleLength - initialCross) / crossDelta,
                    to: &boundaries
                )
            }

            let initialProjection = (segmentStart - capsuleStart).dot(capsuleVector)
            let projectionDelta = segmentVector.dot(capsuleVector)

            if abs(projectionDelta) > tolerance {
                appendBoundary(-initialProjection / projectionDelta, to: &boundaries)
                appendBoundary(
                    (capsuleLengthSquared - initialProjection) / projectionDelta,
                    to: &boundaries
                )
            }
        }

        boundaries.sort()
        boundaries = boundaries.reduce(into: []) { uniqueBoundaries, value in
            if let last = uniqueBoundaries.last,
               abs(last - value) <= tolerance {
                return
            }
            uniqueBoundaries.append(value)
        }

        var retained: [ClosedRange<CGFloat>] = []
        for (lowerBound, upperBound) in zip(boundaries, boundaries.dropFirst()) {
            guard upperBound - lowerBound > tolerance else { continue }

            let midpoint = (lowerBound + upperBound) / 2
            let point = segmentStart.interpolated(to: segmentEnd, progress: midpoint)
            let isErased = point.distanceSquared(
                toSegmentFrom: capsuleStart,
                to: capsuleEnd
            ) <= radius * radius

            if !isErased {
                if let lastInterval = retained.last,
                   abs(lastInterval.upperBound - lowerBound) <= tolerance {
                    retained[retained.count - 1] =
                        lastInterval.lowerBound...upperBound
                } else {
                    retained.append(lowerBound...upperBound)
                }
            }
        }

        return retained
    }

    static func coversEntireSegment(_ intervals: [ClosedRange<CGFloat>]) -> Bool {
        guard intervals.count == 1, let interval = intervals.first else {
            return false
        }

        return interval.lowerBound <= tolerance
            && interval.upperBound >= 1 - tolerance
    }

    private static func appendCircleIntersections(
        center: CGPoint,
        radius: CGFloat,
        segmentStart: CGPoint,
        segmentVector: CGVector,
        to boundaries: inout [CGFloat]
    ) {
        let fromCenter = segmentStart - center
        let a = segmentVector.lengthSquared
        guard a > tolerance else { return }

        let b = 2 * fromCenter.dot(segmentVector)
        let c = fromCenter.lengthSquared - radius * radius
        let discriminant = b * b - 4 * a * c
        guard discriminant >= 0 else { return }

        let root = sqrt(max(discriminant, 0))
        appendBoundary((-b - root) / (2 * a), to: &boundaries)
        appendBoundary((-b + root) / (2 * a), to: &boundaries)
    }

    private static func appendBoundary(
        _ value: CGFloat,
        to boundaries: inout [CGFloat]
    ) {
        guard value > tolerance, value < 1 - tolerance else { return }
        boundaries.append(value)
    }
}

private extension CGPoint {
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGVector {
        CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
    }

    func interpolated(to other: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(
            x: x + (other.x - x) * progress,
            y: y + (other.y - y) * progress
        )
    }

    func distanceSquared(
        toSegmentFrom segmentStart: CGPoint,
        to segmentEnd: CGPoint
    ) -> CGFloat {
        let segment = segmentEnd - segmentStart
        let lengthSquared = segment.lengthSquared

        guard lengthSquared > SegmentClipper.tolerance else {
            return (self - segmentStart).lengthSquared
        }

        let projection = ((self - segmentStart).dot(segment) / lengthSquared)
            .clamped(to: 0...1)
        let closestPoint = segmentStart.interpolated(
            to: segmentEnd,
            progress: projection
        )
        return (self - closestPoint).lengthSquared
    }

    func isApproximatelyEqual(to other: CGPoint) -> Bool {
        (self - other).lengthSquared
            <= SegmentClipper.tolerance * SegmentClipper.tolerance
    }
}

private extension CGVector {
    var lengthSquared: CGFloat {
        dx * dx + dy * dy
    }

    func dot(_ other: CGVector) -> CGFloat {
        dx * other.dx + dy * other.dy
    }

    func cross(_ other: CGVector) -> CGFloat {
        dx * other.dy - dy * other.dx
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
