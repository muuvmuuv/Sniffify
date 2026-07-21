//
//  OnboardingView.swift
//  Sniffify
//
//  First launch: satirical 18+ splash (with the Schneekönig-vs-Sniffify icon
//  gag from the sketch), then height/weight for the official line formula.
//

import SwiftUI

struct OnboardingView: View {
	@AppStorage("heightCm") private var heightCm = 180.0
	@AppStorage("weightKg") private var weightKg = 80.0
	@AppStorage("hasOnboarded") private var hasOnboarded = false

	@State private var step = 0

	var body: some View {
		ZStack {
			PaperBackground()

			if step == 0 {
				splash
			} else {
				profile
			}
		}
	}

	// MARK: - Splash

	private var splash: some View {
		VStack(spacing: AppSpacing.sectionSpacing) {
			Spacer()

			Text("SNIFFIFY")
				.font(DoodleFont.wordmark(46))
				.foregroundStyle(PaperColors.marker)

			NoseDoodle()
				.frame(width: 130, height: 130)

			HStack(spacing: AppSpacing.xxl) {
				iconOption(emoji: "🚜", name: "Schneekönig", mark: "✗", markColor: PaperColors.cross)
				iconOption(emoji: "👃", name: "Sniffify", mark: "✓", markColor: PaperColors.check)
			}

			Text("Reine Satire unter Erwachsenen.\nFunktioniert ausschließlich mit Schnupftabak.")
				.font(DoodleFont.hand(15))
				.foregroundStyle(PaperColors.pencil)
				.multilineTextAlignment(.center)

			Spacer()

			Button("Ich bin volljährig") {
				withAnimation(AppAnimations.smooth) { step = 1 }
			}
			.buttonStyle(DoodleButtonStyle(color: PaperColors.marker))
			.padding(.bottom, AppSpacing.xxxl)
		}
		.padding(AppSpacing.screenPadding)
	}

	private func iconOption(emoji: String, name: String, mark: String, markColor: Color) -> some View {
		VStack(spacing: AppSpacing.sm) {
			ZStack {
				RoughRect(seed: UInt64(name.count))
					.stroke(PaperColors.ink, lineWidth: 2.5)
					.frame(width: 84, height: 84)
				Text(emoji)
					.font(.system(size: 44))
				Text(mark)
					.font(DoodleFont.wordmark(64))
					.foregroundStyle(markColor)
					.rotationEffect(.degrees(-8))
			}
			Text(name)
				.font(DoodleFont.heading(15))
				.foregroundStyle(PaperColors.marker)
		}
	}

	// MARK: - Profile

	private var profile: some View {
		VStack(spacing: AppSpacing.sectionSpacing) {
			Spacer()

			Text("Die Wissenschaft braucht Daten.")
				.font(DoodleFont.heading(24))
				.foregroundStyle(PaperColors.ink)
				.multilineTextAlignment(.center)

			VStack(spacing: AppSpacing.xl) {
				VStack(spacing: AppSpacing.xs) {
					Text("Größe: \(Int(heightCm)) cm")
						.font(DoodleFont.hand(17))
					Slider(value: $heightCm, in: 140...210, step: 1)
				}
				VStack(spacing: AppSpacing.xs) {
					Text("Gewicht: \(Int(weightKg)) kg")
						.font(DoodleFont.hand(17))
					Slider(value: $weightKg, in: 40...200, step: 1)
				}
			}
			.foregroundStyle(PaperColors.ink)
			.tint(PaperColors.marker)

			VStack(spacing: AppSpacing.md) {
				SegmentedLineView()
					.frame(
						width: 140
							+ (Sniffonomics.lineLengthCm(heightCm: heightCm, weightKg: weightKg) - 5) * 25,
						height: Sniffonomics.lineWidthMm(weightKg: weightKg) * 2
					)
					.animation(AppAnimations.standard, value: heightCm + weightKg)

				Text(
					"Deine offizielle Line: \(Sniffonomics.lineLengthCm(heightCm: heightCm, weightKg: weightKg).formatted(.number.precision(.fractionLength(1)))) cm"
				)
				.font(DoodleFont.hand(15))
				.foregroundStyle(PaperColors.pencil)
			}

			Spacer()

			Button("Los geht's 👃") {
				hasOnboarded = true
			}
			.buttonStyle(DoodleButtonStyle(color: PaperColors.marker))
			.padding(.bottom, AppSpacing.xxxl)
		}
		.padding(AppSpacing.screenPadding)
	}
}

#Preview {
	OnboardingView()
}
