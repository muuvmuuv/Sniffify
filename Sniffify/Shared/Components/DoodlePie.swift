//
//  DoodlePie.swift
//  Sniffify
//
//  Pie-slice shape (also the countdown sweep wedge) and the hand-drawn
//  two-slice pie chart from the Wrapped mockup.
//

import SwiftUI

struct PieSliceShape: Shape {
	var start: Angle
	var end: Angle

	func path(in rect: CGRect) -> Path {
		var path = Path()
		let center = CGPoint(x: rect.midX, y: rect.midY)
		let radius = min(rect.width, rect.height) / 2
		path.move(to: center)
		path.addArc(center: center, radius: radius, startAngle: start, endAngle: end, clockwise: false)
		path.closeSubpath()
		return path
	}
}

/// Two-slice doodle pie: the smaller "mit Freunden" slice is pulled out of
/// the circle like in the sketch.
struct DoodlePie: View {
	/// Fraction 0...1 of the first ("Alleine") slice.
	var aloneFraction: Double

	private var splitAngle: Angle { .degrees(-90 + 360 * aloneFraction) }

	var body: some View {
		GeometryReader { proxy in
			let side = min(proxy.size.width, proxy.size.height)
			let bisector = (-90 + 360 * aloneFraction + (360 - 360 * aloneFraction) / 2) * .pi / 180
			let pullOut = CGSize(width: cos(bisector) * side * 0.06, height: sin(bisector) * side * 0.06)

			ZStack {
				PieSliceShape(start: .degrees(-90), end: splitAngle)
					.stroke(PaperColors.ink, lineWidth: 3)

				PieSliceShape(start: splitAngle, end: .degrees(270))
					.fill(PaperColors.marker.opacity(0.18))
					.overlay(PieSliceShape(start: splitAngle, end: .degrees(270)).stroke(PaperColors.ink, lineWidth: 3))
					.offset(pullOut)

				percentLabel(
					String(format: "%.0f %%", aloneFraction * 100), angle: -90 + 360 * aloneFraction / 2, side: side)
				percentLabel(
					String(format: "%.0f %%", (1 - aloneFraction) * 100),
					angle: -90 + 360 * aloneFraction + 360 * (1 - aloneFraction) / 2,
					side: side
				)
			}
			.frame(width: proxy.size.width, height: proxy.size.height)
		}
	}

	private func percentLabel(_ text: String, angle: Double, side: CGFloat) -> some View {
		let radians = angle * .pi / 180
		return Text(text)
			.font(DoodleFont.hand(side * 0.12))
			.foregroundStyle(PaperColors.marker)
			.offset(
				x: cos(radians) * side * 0.62,
				y: sin(radians) * side * 0.62
			)
	}
}

#Preview {
	ZStack {
		PaperBackground()
		DoodlePie(aloneFraction: 0.72)
			.frame(width: 180, height: 180)
	}
}
