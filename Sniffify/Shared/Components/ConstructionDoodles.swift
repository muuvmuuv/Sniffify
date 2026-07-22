//
//  ConstructionDoodles.swift
//  Sniffify
//
//  The hand-drawn construction crew flanking the line — stick-figure
//  builders, striped traffic cones — and the shovel buddies that clear a
//  finished line: the yellow hard-hatted blob on day shift, the Sandmann
//  on night shift.
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

/// The yellow hard-hatted blob who shovels the finished line away.
struct ShovelerDoodle: View {
	var body: some View {
		Canvas { context, size in
			let s = size.width / 100
			func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
			let ink = GraphicsContext.Shading.color(PaperColors.ink)
			let stroke = StrokeStyle(lineWidth: 3 * s, lineCap: .round, lineJoin: .round)
			let bodyYellow = Color(red: 0.98, green: 0.82, blue: 0.20)

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

			// hard hat, same style as BuilderDoodle's
			var hat = Path()
			hat.move(to: point(34, 18))
			hat.addQuadCurve(to: point(66, 18), control: point(50, 2))
			hat.closeSubpath()
			context.fill(hat, with: .color(PaperColors.crown))
			context.stroke(hat, with: ink, style: stroke)
			var brim = Path()
			brim.move(to: point(28, 18))
			brim.addLine(to: point(72, 18))
			context.stroke(brim, with: ink, style: stroke)

			// two plain eyes
			for eyeX: CGFloat in [37, 52] {
				let eye = Path(ellipseIn: CGRect(x: eyeX * s, y: 27 * s, width: 11 * s, height: 13 * s))
				context.fill(eye, with: .color(.white))
				context.stroke(eye, with: ink, style: StrokeStyle(lineWidth: 2.5 * s))
				let pupil = Path(ellipseIn: CGRect(x: (eyeX + 3) * s, y: 32 * s, width: 5 * s, height: 5 * s))
				context.fill(pupil, with: ink)
			}

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

/// The night-shift shovel buddy: folklore sandman with nightcap, beard,
/// and a trail of golden Schlafsand — nothing from the TV puppet.
struct SandmannDoodle: View {
	var body: some View {
		Canvas { context, size in
			let s = size.width / 100
			func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
			let ink = GraphicsContext.Shading.color(PaperColors.ink)
			let stroke = StrokeStyle(lineWidth: 3 * s, lineCap: .round, lineJoin: .round)

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

			// nightgown
			var gown = Path()
			gown.move(to: point(42, 34))
			gown.addLine(to: point(32, 82))
			gown.addQuadCurve(to: point(68, 82), control: point(50, 90))
			gown.addLine(to: point(58, 34))
			gown.addQuadCurve(to: point(42, 34), control: point(50, 38))
			gown.closeSubpath()
			context.fill(gown, with: .color(PaperColors.marker))
			context.stroke(gown, with: ink, style: stroke)

			// arms: left grips the shovel, right sprinkles sand
			var arms = Path()
			arms.move(to: point(42, 44))
			arms.addLine(to: point(16, 38))
			arms.move(to: point(58, 42))
			arms.addLine(to: point(80, 30))
			context.stroke(arms, with: ink, style: stroke)

			// Schlafsand trickling from the raised hand
			for (x, y, r) in [(84.0, 36.0, 2.5), (88.0, 44.0, 2.0), (83.0, 52.0, 2.5), (89.0, 59.0, 1.8)] {
				let grain = Path(
					ellipseIn: CGRect(
						x: (x - r) * s, y: (y - r) * s, width: 2 * r * s, height: 2 * r * s))
				context.fill(grain, with: .color(PaperColors.crown))
				context.stroke(grain, with: ink, style: StrokeStyle(lineWidth: 1.2 * s))
			}

			// head
			let head = Path(ellipseIn: CGRect(x: 39 * s, y: 11 * s, width: 22 * s, height: 22 * s))
			context.fill(head, with: .color(.white.opacity(0.6)))
			context.stroke(head, with: ink, style: stroke)

			// pointed beard
			var beard = Path()
			beard.move(to: point(40, 27))
			beard.addQuadCurve(to: point(50, 52), control: point(42, 46))
			beard.addQuadCurve(to: point(60, 27), control: point(58, 46))
			beard.addQuadCurve(to: point(40, 27), control: point(50, 34))
			beard.closeSubpath()
			context.fill(beard, with: .color(.white))
			context.stroke(beard, with: ink, style: StrokeStyle(lineWidth: 2.5 * s, lineJoin: .round))

			// floppy nightcap with tassel
			var cap = Path()
			cap.move(to: point(36, 16))
			cap.addQuadCurve(to: point(76, 10), control: point(44, -8))
			cap.addQuadCurve(to: point(62, 16), control: point(66, 8))
			cap.closeSubpath()
			context.fill(cap, with: .color(PaperColors.cross))
			context.stroke(cap, with: ink, style: stroke)
			let tassel = Path(ellipseIn: CGRect(x: 74 * s, y: 8 * s, width: 6 * s, height: 6 * s))
			context.fill(tassel, with: .color(PaperColors.crown))
			context.stroke(tassel, with: ink, style: StrokeStyle(lineWidth: 1.5 * s))

			// sleepy closed eyes
			var eyes = Path()
			eyes.move(to: point(43, 22))
			eyes.addQuadCurve(to: point(48, 22), control: point(45.5, 25))
			eyes.move(to: point(52, 22))
			eyes.addQuadCurve(to: point(57, 22), control: point(54.5, 25))
			context.stroke(eyes, with: ink, style: StrokeStyle(lineWidth: 2 * s, lineCap: .round))
		}
		.aspectRatio(1, contentMode: .fit)
	}
}

/// The shovel buddy on duty: Sandmann after dem Abendgruß, blob otherwise.
/// The settings picker ("lineHelper") can pin one of the two; empty means
/// the shift plan decides.
struct LineHelperDoodle: View {
	@AppStorage("lineHelper") private var lineHelper = ""

	var body: some View {
		let hour = Calendar.current.component(.hour, from: .now)
		if lineHelper == "sandmann" || (lineHelper.isEmpty && hour >= 19) {
			SandmannDoodle()
		} else {
			ShovelerDoodle()
		}
	}
}

#Preview {
	ZStack {
		PaperBackground()
		HStack(spacing: 30) {
			BuilderDoodle().frame(width: 70)
			ConeDoodle().frame(width: 50)
			ShovelerDoodle().frame(width: 90)
			SandmannDoodle().frame(width: 90)
		}
	}
}
