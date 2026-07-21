//
//  NoseDoodle.swift
//  Sniffify
//
//  The crowned nose — Sniffify's logo, wallpaper tile, mascot body, and
//  confetti particle. One Path, reused everywhere.
//

import SwiftUI

/// Side-view blobby nose in a 100×100 unit space, pointing left.
struct NoseShape: Shape {
	func path(in rect: CGRect) -> Path {
		let w = rect.width / 100
		let h = rect.height / 100
		func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
			CGPoint(x: rect.minX + x * w, y: rect.minY + y * h)
		}

		var path = Path()
		path.move(to: point(62, 8))
		// bridge sloping down-left
		path.addQuadCurve(to: point(38, 52), control: point(48, 28))
		// big round tip
		path.addQuadCurve(to: point(30, 82), control: point(12, 62))
		// nostril underside
		path.addQuadCurve(to: point(58, 86), control: point(42, 96))
		// nostril wing
		path.addQuadCurve(to: point(72, 74), control: point(70, 88))
		// back up the right side
		path.addQuadCurve(to: point(62, 8), control: point(80, 40))
		path.closeSubpath()
		return path
	}
}

/// Three-spike crown in a 100×100 unit space.
struct CrownShape: Shape {
	func path(in rect: CGRect) -> Path {
		let w = rect.width / 100
		let h = rect.height / 100
		func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
			CGPoint(x: rect.minX + x * w, y: rect.minY + y * h)
		}

		var path = Path()
		path.move(to: point(10, 90))
		path.addLine(to: point(5, 25))
		path.addLine(to: point(30, 55))
		path.addLine(to: point(50, 10))
		path.addLine(to: point(70, 55))
		path.addLine(to: point(95, 25))
		path.addLine(to: point(90, 90))
		path.closeSubpath()
		return path
	}
}

/// Simple three-feather wing in a 100×100 unit space, pointing left.
struct WingShape: Shape {
	func path(in rect: CGRect) -> Path {
		let w = rect.width / 100
		let h = rect.height / 100
		func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
			CGPoint(x: rect.minX + x * w, y: rect.minY + y * h)
		}

		var path = Path()
		path.move(to: point(95, 55))
		path.addQuadCurve(to: point(5, 20), control: point(45, 5))
		path.addQuadCurve(to: point(40, 55), control: point(25, 45))
		path.addQuadCurve(to: point(20, 80), control: point(28, 65))
		path.addQuadCurve(to: point(95, 55), control: point(60, 85))
		path.closeSubpath()
		return path
	}
}

/// The crowned (optionally winged) nose doodle.
struct NoseDoodle: View {
	var crowned = true
	var winged = false
	var stroke: Color = PaperColors.ink
	var fill: Color = PaperColors.noseSkin

	var body: some View {
		GeometryReader { proxy in
			let side = min(proxy.size.width, proxy.size.height)
			ZStack {
				if winged {
					WingShape()
						.fill(.white)
						.overlay(WingShape().stroke(stroke, lineWidth: side * 0.02))
						.frame(width: side * 0.5, height: side * 0.35)
						.offset(x: -side * 0.28, y: side * 0.05)
					WingShape()
						.fill(.white)
						.overlay(WingShape().stroke(stroke, lineWidth: side * 0.02))
						.scaleEffect(x: -1)
						.frame(width: side * 0.5, height: side * 0.35)
						.offset(x: side * 0.38, y: side * 0.05)
				}

				NoseShape()
					.fill(fill)
					.overlay(NoseShape().stroke(stroke, lineWidth: side * 0.03))
					.frame(width: side * 0.8, height: side * 0.8)
					.offset(y: side * 0.12)

				if crowned {
					CrownShape()
						.fill(PaperColors.crown)
						.overlay(CrownShape().stroke(stroke, lineWidth: side * 0.02))
						.frame(width: side * 0.34, height: side * 0.22)
						.rotationEffect(.degrees(12))
						.offset(x: side * 0.16, y: -side * 0.3)
				}
			}
			.frame(width: proxy.size.width, height: proxy.size.height)
		}
	}
}

#Preview {
	ZStack {
		PaperBackground()
		VStack(spacing: 40) {
			NoseDoodle().frame(width: 120, height: 120)
			NoseDoodle(winged: true).frame(width: 160, height: 160)
		}
	}
}
