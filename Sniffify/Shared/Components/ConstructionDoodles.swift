//
//  ConstructionDoodles.swift
//  Sniffify
//
//  The hand-drawn construction crew flanking the line — stick-figure
//  builders, striped traffic cones — and the yellow one-goggled shovel
//  helper that clears a finished line (a doodle homage, not licensed art).
//

import SwiftUI

/// Stick-figure worker with a yellow hard hat, waving.
struct BuilderDoodle: View {
	var body: some View {
		Canvas { context, size in
			let s = size.width / 100
			func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
			let ink = GraphicsContext.Shading.color(PaperColors.ink)
			let stroke = StrokeStyle(lineWidth: 3 * s, lineCap: .round, lineJoin: .round)

			// head
			let head = Path(ellipseIn: CGRect(x: 39 * s, y: 14 * s, width: 22 * s, height: 22 * s))
			context.fill(head, with: .color(.white.opacity(0.6)))
			context.stroke(head, with: ink, style: stroke)

			// hard hat
			var hat = Path()
			hat.move(to: point(36, 16))
			hat.addQuadCurve(to: point(64, 16), control: point(50, 2))
			hat.closeSubpath()
			context.fill(hat, with: .color(PaperColors.crown))
			context.stroke(hat, with: ink, style: stroke)
			var brim = Path()
			brim.move(to: point(32, 16))
			brim.addLine(to: point(68, 16))
			context.stroke(brim, with: ink, style: stroke)

			// body, arms (one waving), legs
			var figure = Path()
			figure.move(to: point(50, 36))
			figure.addLine(to: point(50, 64))
			figure.move(to: point(50, 44))
			figure.addLine(to: point(30, 30))
			figure.move(to: point(50, 48))
			figure.addLine(to: point(68, 56))
			figure.move(to: point(50, 64))
			figure.addLine(to: point(38, 86))
			figure.move(to: point(50, 64))
			figure.addLine(to: point(62, 86))
			context.stroke(figure, with: ink, style: stroke)
		}
		.aspectRatio(1, contentMode: .fit)
	}
}

/// Striped traffic cone.
struct ConeDoodle: View {
	var body: some View {
		Canvas { context, size in
			let s = size.width / 100
			func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
			let ink = GraphicsContext.Shading.color(PaperColors.ink)
			let stroke = StrokeStyle(lineWidth: 3 * s, lineCap: .round, lineJoin: .round)

			var cone = Path()
			cone.move(to: point(50, 12))
			cone.addLine(to: point(32, 78))
			cone.addLine(to: point(68, 78))
			cone.closeSubpath()
			context.fill(cone, with: .color(PaperColors.cone))
			context.stroke(cone, with: ink, style: stroke)

			// white band
			var band = Path()
			band.move(to: point(42, 42))
			band.addLine(to: point(58, 42))
			band.addLine(to: point(61, 54))
			band.addLine(to: point(39, 54))
			band.closeSubpath()
			context.fill(band, with: .color(.white.opacity(0.85)))
			context.stroke(band, with: ink, style: StrokeStyle(lineWidth: 2 * s))

			// base
			let base = Path(
				roundedRect: CGRect(x: 22 * s, y: 78 * s, width: 56 * s, height: 9 * s),
				cornerRadius: 3 * s)
			context.fill(base, with: .color(PaperColors.cone))
			context.stroke(base, with: ink, style: stroke)
		}
		.aspectRatio(1, contentMode: .fit)
	}
}

/// The yellow one-goggled helper who shovels the finished line away.
struct ShovelerDoodle: View {
	var body: some View {
		Canvas { context, size in
			let s = size.width / 100
			func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
			let ink = GraphicsContext.Shading.color(PaperColors.ink)
			let stroke = StrokeStyle(lineWidth: 3 * s, lineCap: .round, lineJoin: .round)
			let bodyYellow = Color(red: 0.98, green: 0.82, blue: 0.20)
			let dungareeBlue = Color(red: 0.25, green: 0.35, blue: 0.75)

			// shovel (behind the body): handle + blade
			var handle = Path()
			handle.move(to: point(16, 24))
			handle.addLine(to: point(10, 72))
			context.stroke(handle, with: ink, style: StrokeStyle(lineWidth: 3.5 * s, lineCap: .round))
			var blade = Path()
			blade.move(to: point(3, 70))
			blade.addLine(to: point(17, 70))
			blade.addLine(to: point(13, 86))
			blade.addLine(to: point(5, 86))
			blade.closeSubpath()
			context.fill(blade, with: .color(Color(white: 0.7)))
			context.stroke(blade, with: ink, style: StrokeStyle(lineWidth: 2.5 * s, lineJoin: .round))

			// capsule body
			let body = Path(
				roundedRect: CGRect(x: 30 * s, y: 14 * s, width: 40 * s, height: 64 * s),
				cornerRadius: 20 * s)
			context.fill(body, with: .color(bodyYellow))
			context.stroke(body, with: ink, style: stroke)

			// dungarees
			var pants = Path(
				roundedRect: CGRect(x: 30 * s, y: 58 * s, width: 40 * s, height: 20 * s),
				cornerRadius: 14 * s)
			pants.addRect(CGRect(x: 30 * s, y: 58 * s, width: 40 * s, height: 8 * s))
			context.fill(pants, with: .color(dungareeBlue))
			var pantsTop = Path()
			pantsTop.move(to: point(30, 58))
			pantsTop.addLine(to: point(70, 58))
			context.stroke(pantsTop, with: ink, style: StrokeStyle(lineWidth: 2.5 * s))
			var straps = Path()
			straps.move(to: point(34, 58))
			straps.addLine(to: point(38, 50))
			straps.move(to: point(66, 58))
			straps.addLine(to: point(62, 50))
			context.stroke(straps, with: .color(dungareeBlue), style: StrokeStyle(lineWidth: 3 * s, lineCap: .round))

			// goggle strap + goggle + eye
			var strap = Path()
			strap.move(to: point(30, 32))
			strap.addLine(to: point(70, 32))
			context.stroke(strap, with: ink, style: StrokeStyle(lineWidth: 4 * s))
			let goggle = Path(ellipseIn: CGRect(x: 40 * s, y: 22 * s, width: 20 * s, height: 20 * s))
			context.fill(goggle, with: .color(Color(white: 0.75)))
			context.stroke(goggle, with: ink, style: stroke)
			let eye = Path(ellipseIn: CGRect(x: 44 * s, y: 26 * s, width: 12 * s, height: 12 * s))
			context.fill(eye, with: .color(.white))
			let pupil = Path(ellipseIn: CGRect(x: 47.5 * s, y: 29.5 * s, width: 5 * s, height: 5 * s))
			context.fill(pupil, with: ink)

			// grin
			var grin = Path()
			grin.move(to: point(43, 48))
			grin.addQuadCurve(to: point(57, 48), control: point(50, 54))
			context.stroke(grin, with: ink, style: StrokeStyle(lineWidth: 2.5 * s, lineCap: .round))

			// arms: left grips the shovel, right swings out
			var arms = Path()
			arms.move(to: point(30, 44))
			arms.addLine(to: point(14, 38))
			arms.move(to: point(70, 44))
			arms.addLine(to: point(84, 54))
			context.stroke(arms, with: ink, style: stroke)

			// feet
			let footLeft = Path(ellipseIn: CGRect(x: 36 * s, y: 78 * s, width: 11 * s, height: 7 * s))
			let footRight = Path(ellipseIn: CGRect(x: 53 * s, y: 78 * s, width: 11 * s, height: 7 * s))
			context.fill(footLeft, with: ink)
			context.fill(footRight, with: ink)
		}
		.aspectRatio(1, contentMode: .fit)
	}
}

#Preview {
	ZStack {
		PaperBackground()
		HStack(spacing: 30) {
			BuilderDoodle().frame(width: 70)
			ConeDoodle().frame(width: 50)
			ShovelerDoodle().frame(width: 90)
		}
	}
}
