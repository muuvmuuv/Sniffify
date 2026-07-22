//
//  SniffResultOverlay.swift
//  Sniffify
//
//  Success: the winged crowned nose swoops along the line and "shovels" it
//  away, praise pops in, nose confetti falls. Fail: tipped cone and mockery.
//

import SwiftUI

struct SniffResultOverlay: View {
	enum Kind {
		case success
		case fail
	}

	let kind: Kind
	let lineFrame: CGRect
	var analysis: String?
	var finishSeconds: Double?
	var onDone: () -> Void
	var onRetry: () -> Void

	private var horizontal: Bool { lineFrame.width >= lineFrame.height }

	@State private var praiseStep = 0
	@State private var confettiFalling = false
	@State private var mascotFlying = false

	var body: some View {
		ZStack {
			switch kind {
			case .success:
				successBody
			case .fail:
				failBody
			}
		}
	}

	// MARK: - Success

	private var successBody: some View {
		ZStack {
			// slow sweep along the line, then he stays put and keeps shoveling
			KeyframeAnimator(initialValue: 0.0, trigger: mascotFlying) { progress in
				TimelineView(.animation) { context in
					let shovelWobble = sin(context.date.timeIntervalSinceReferenceDate * 5) * 7

					if horizontal {
						LineHelperDoodle()
							.frame(width: 130, height: 130)
							.rotationEffect(.degrees(shovelWobble))
							.position(
								x: lineFrame.minX - 60 + (lineFrame.width + 60) * progress,
								y: lineFrame.midY - 40 - sin(progress * .pi) * 24
							)
					} else {
						LineHelperDoodle()
							.frame(width: 130, height: 130)
							.rotationEffect(.degrees(shovelWobble))
							.position(
								x: lineFrame.midX - 60 - sin(progress * .pi) * 24,
								y: lineFrame.minY - 60 + (lineFrame.height + 60) * progress
							)
					}
				}
			} keyframes: { _ in
				LinearKeyframe(1.0, duration: 2.6)
			}

			confetti

			VStack(spacing: AppSpacing.lg) {
				if praiseStep >= 1 {
					Text("Du bist spitze!")
						.font(DoodleFont.wordmark(34))
						.foregroundStyle(PaperColors.marker)
						.rotationEffect(.degrees(-4))
						.transition(.scale.combined(with: .opacity))
				}
				if praiseStep >= 2 {
					Text("Hör doch auf, du bist spitze!")
						.font(DoodleFont.heading(20))
						.foregroundStyle(PaperColors.ink)
						.rotationEffect(.degrees(2))
						.transition(.scale.combined(with: .opacity))
				}
				if praiseStep >= 1, let finishSeconds {
					Text(
						"⏱ \(finishSeconds.formatted(.number.precision(.fractionLength(1)))) s"
							+ (finishSeconds <= SniffSessionViewModel.perfectTime ? " — PERFEKT!" : "")
					)
					.font(DoodleFont.heading(18))
					.foregroundStyle(
						finishSeconds <= SniffSessionViewModel.perfectTime
							? PaperColors.check : PaperColors.ink
					)
					.transition(.scale.combined(with: .opacity))
				}
				if praiseStep >= 2, let analysis {
					Text(analysis)
						.font(DoodleFont.hand(14))
						.foregroundStyle(PaperColors.pencil)
						.transition(.opacity)
				}
			}
			.offset(y: horizontal ? -90 : -180)

			actions(primary: "Fertig 👑", secondary: "Nochmal")
		}
		.task {
			mascotFlying = true
			try? await Task.sleep(for: .seconds(0.4))
			withAnimation(AppAnimations.bouncy) { praiseStep = 1 }
			try? await Task.sleep(for: .seconds(1.1))
			withAnimation(AppAnimations.bouncy) { praiseStep = 2 }
		}
	}

	private var confetti: some View {
		GeometryReader { proxy in
			ForEach(0..<12, id: \.self) { index in
				var rng = SeededGenerator(seed: UInt64(index) &+ 900)
				let x = CGFloat.random(in: 20...(proxy.size.width - 20), using: &rng)
				let size = CGFloat.random(in: 18...34, using: &rng)
				let delay = Double.random(in: 0...0.8, using: &rng)
				let spin = Double.random(in: -220...220, using: &rng)

				NoseDoodle(crowned: false, stroke: PaperColors.pencil, fill: PaperColors.noseSkin.opacity(0.7))
					.frame(width: size, height: size)
					.rotationEffect(.degrees(confettiFalling ? spin : 0))
					.position(x: x, y: confettiFalling ? proxy.size.height + 60 : -60)
					.animation(.linear(duration: 2.4).delay(delay), value: confettiFalling)
			}
		}
		.allowsHitTesting(false)
		.onAppear { confettiFalling = true }
	}

	// MARK: - Fail

	private var failBody: some View {
		ZStack {
			VStack(spacing: AppSpacing.lg) {
				Text("🚧")
					.font(.system(size: 56))
					.rotationEffect(.degrees(-70))
				Text("Daneben geniest!")
					.font(DoodleFont.wordmark(30))
					.foregroundStyle(PaperColors.cross)
					.rotationEffect(.degrees(-3))
				Text("Die Baustelle bleibt bestehen.")
					.font(DoodleFont.hand(16))
					.foregroundStyle(PaperColors.pencil)
			}
			.offset(y: horizontal ? -90 : -180)

			actions(primary: "Aufgeben", secondary: "Nochmal")
		}
	}

	// MARK: - Shared

	private func actions(primary: String, secondary: String) -> some View {
		VStack {
			Spacer()
			HStack(spacing: AppSpacing.xxl) {
				Button(secondary) { onRetry() }
					.buttonStyle(DoodleButtonStyle())
				Button(primary) { onDone() }
					.buttonStyle(DoodleButtonStyle(color: PaperColors.marker))
			}
			.padding(.bottom, 120)
		}
	}
}

#Preview {
	ZStack {
		PaperBackground()
		SniffResultOverlay(
			kind: .success,
			lineFrame: CGRect(x: 40, y: 400, width: 300, height: 12),
			analysis: "Analyse: Direktzug, respektvoll klassisch 👃",
			finishSeconds: 1.2,
			onDone: {},
			onRetry: {}
		)
	}
}
