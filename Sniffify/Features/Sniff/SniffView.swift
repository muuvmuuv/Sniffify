//
//  SniffView.swift
//  Sniffify
//
//  Main tab: your personal line preview, the "mit Freunden" toggle, and the
//  entry into the locked sniff session.
//

import SwiftUI

struct SniffView: View {
	@AppStorage("heightCm") private var heightCm = 180.0
	@AppStorage("weightKg") private var weightKg = 80.0
	@AppStorage("debugAudioCapture") private var debugAudioCapture = false
	@Environment(\.displayScale) private var displayScale
	@Environment(\.openURL) private var openURL
	@State private var withFriends = false
	@State private var showSession = false
	@State private var showMicDenied = false

	private var lineLengthCm: Double {
		Sniffonomics.lineLengthCm(heightCm: heightCm, weightKg: weightKg)
	}

	private var lineWidthMm: Double {
		Sniffonomics.lineWidthMm(weightKg: weightKg)
	}

	var body: some View {
		GeometryReader { proxy in
			let lengthPt = lineLengthCm * Sniffonomics.pointsPerCm(displayScale: displayScale)
			let truncated = lengthPt > max(proxy.size.width, proxy.size.height) * 0.55

			ZStack {
				PaperBackground()
				NoseWallpaper()

				VStack(spacing: AppSpacing.sectionSpacing) {
					Text("SNIFFIFY")
						.font(DoodleFont.wordmark(42))
						.foregroundStyle(PaperColors.marker)
						.padding(.top, AppSpacing.xxl)

					Spacer()

					VStack(spacing: AppSpacing.lg) {
						Text("Deine offizielle Line")
							.font(DoodleFont.hand(17))
							.foregroundStyle(PaperColors.pencil)

						HStack(alignment: .bottom, spacing: AppSpacing.md) {
							BuilderDoodle()
								.frame(width: 40)
							let previewWidth = 120 + (lineLengthCm - 5) * 25
							let lineHeight = CGFloat(lineWidthMm) * 2
							SegmentedLineView()
								.frame(width: previewWidth, height: lineHeight)
								.overlay(alignment: .topLeading) {
									// helper patrols the line, pushing the heap ahead of his shovel;
									// feet (78–85 % of the 80 pt doodle) land inside the line band
									TimelineView(.animation) { context in
										let t = context.date.timeIntervalSinceReferenceDate
										let progress = (sin(t * 0.7) + 1) / 2
										HStack(alignment: .bottom, spacing: -8) {
											SnowHeapDoodle()
												.frame(width: 44, height: 20)
												.offset(y: -8)
											// explicit height: the overlay proposes the line's ~10 pt,
											// which would shrink the aspect-fitted doodle to 10×10
											LineHelperDoodle()
												.frame(width: 80, height: 80)
												.rotationEffect(.degrees(sin(t * 5) * 4))
										}
										.offset(
											x: progress * max(0, previewWidth - 116), y: lineHeight / 2 - 68)
									}
								}
								.padding(.top, 48)
							ConeDoodle()
								.frame(width: 28)
						}

						Text(
							"Amtlich: \(lineLengthCm.formatted(.number.precision(.fractionLength(1)))) cm × \(lineWidthMm.formatted(.number.precision(.fractionLength(1)))) mm"
								+ (truncated ? "\n(Bildschirm zu kurz — wird amtlich gekürzt)" : "")
						)
						.font(DoodleFont.heading(18))
						.multilineTextAlignment(.center)
						.foregroundStyle(PaperColors.ink)
					}

					Toggle(isOn: $withFriends) {
						Text("Mit Freunden")
							.font(DoodleFont.hand(17))
							.foregroundStyle(PaperColors.ink)
					}
					.tint(PaperColors.marker)
					.frame(width: 220)

					Spacer()

					Text("Tabak in die Box, Röhrchen ansetzen.\nTimer starten — bei Null ziehst du.")
						.font(DoodleFont.hand(15))
						.multilineTextAlignment(.center)
						.foregroundStyle(PaperColors.pencil)

					Button("Ziehen 👃") {
						Task {
							if await SniffAudioService.requestPermission() {
								showSession = true
							} else {
								showMicDenied = true
							}
						}
					}
					.buttonStyle(DoodleButtonStyle(color: PaperColors.marker))
					.padding(.bottom, AppSpacing.xxxl)
				}
				.padding(AppSpacing.screenPadding)
			}
		}
		.fullScreenCover(isPresented: $showSession) {
			SniffSessionView(
				lineLengthCm: lineLengthCm,
				lineWidthMm: lineWidthMm,
				withFriends: withFriends,
				debugCapture: debugAudioCapture
			)
		}
		.alert("Ohne Mikro kein Zug", isPresented: $showMicDenied) {
			Button("Einstellungen") {
				if let url = URL(string: UIApplication.openSettingsURLString) {
					openURL(url)
				}
			}
			Button("Abbrechen", role: .cancel) {}
		} message: {
			Text(
				"Sniffify hört, wie du ziehst — ein Röhrchen sieht der Bildschirm nicht. Erlaub das Mikrofon in den Einstellungen."
			)
		}
	}
}

/// The little powder heap the shovel buddy works on next to the preview line.
private struct SnowHeapDoodle: View {
	var body: some View {
		Canvas { context, size in
			var mound = Path()
			mound.move(to: CGPoint(x: 0, y: size.height))
			mound.addQuadCurve(
				to: CGPoint(x: size.width * 0.7, y: size.height),
				control: CGPoint(x: size.width * 0.35, y: -size.height * 0.5))
			mound.closeSubpath()
			context.fill(mound, with: .color(.white))
			context.stroke(
				mound, with: .color(PaperColors.pencil),
				style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))

			// loose grains flying by the shovel blade
			for (x, y, r): (CGFloat, CGFloat, CGFloat) in [
				(size.width * 0.82, size.height * 0.5, 1.7), (size.width * 0.95, size.height * 0.75, 1.3),
			] {
				let grain = Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
				context.fill(grain, with: .color(.white))
				context.stroke(grain, with: .color(PaperColors.pencil), style: StrokeStyle(lineWidth: 1))
			}
		}
	}
}

#Preview {
	SniffView()
}
