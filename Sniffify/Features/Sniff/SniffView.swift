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
	@State private var withFriends = false
	@State private var showSession = false
	@State private var micAuthorized = false

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

						HStack(spacing: AppSpacing.md) {
							BuilderDoodle()
								.frame(width: 40)
							SegmentedLineView()
								.frame(
									width: 120 + (lineLengthCm - 5) * 25,
									height: CGFloat(lineWidthMm) * 2
								)
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

					Text("Tabak in die Box, Nase auf die lila Spur.\nTimer starten — bei Null ziehst du.")
						.font(DoodleFont.hand(15))
						.multilineTextAlignment(.center)
						.foregroundStyle(PaperColors.pencil)

					Button("Ziehen 👃") {
						Task {
							micAuthorized = await SniffAudioService.requestPermission()
							showSession = true
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
				micAuthorized: micAuthorized,
				debugCapture: debugAudioCapture
			)
		}
	}
}

#Preview {
	SniffView()
}
