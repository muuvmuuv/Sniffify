//
//  SniffSessionView.swift
//  Sniffify
//
//  The locked full-screen sniff session: briefing, film countdown, armed
//  window with the line clearing as the pull is heard, and the success/fail
//  result overlays. The line renders at true physical size along the
//  screen's long axis (vertical in portrait, horizontal in landscape).
//  Screen stays awake, system edges are deferred; exit only by holding the
//  lock.
//

import SwiftData
import SwiftUI

struct SniffSessionView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.displayScale) private var displayScale

	@State private var vm: SniffSessionViewModel
	@State private var recorded = false
	@State private var escapePressing = false

	init(
		lineLengthCm: Double, lineWidthMm: Double, withFriends: Bool, debugCapture: Bool
	) {
		_vm = State(
			initialValue: SniffSessionViewModel(
				lineLengthCm: lineLengthCm,
				lineWidthMm: lineWidthMm,
				withFriends: withFriends,
				debugCapture: debugCapture
			))
	}

	private struct LineLayout: Equatable {
		/// Where the tobacco physically lies: a rough outlined box.
		let boxFrame: CGRect
		/// The parallel progress track: its dashes vanish as the pull is heard.
		let trackFrame: CGRect
		let axis: Axis
		let truncated: Bool
	}

	/// Gap between progress track and tobacco box, so the tube never hovers
	/// over the track and the dashes stay visible.
	private static let trackGap: CGFloat = 90
	private static let trackThickness: CGFloat = 12

	var body: some View {
		GeometryReader { proxy in
			let layout = lineLayout(in: proxy.size)
			let overlayOffset = -proxy.size.height * (layout.axis == .vertical ? 0.33 : 0.22)

			ZStack {
				PaperBackground()
				NoseWallpaper().opacity(0.5)

				// once it's done, it's done — only the end screen remains
				if vm.phase != .success && vm.phase != .fail {
					lineArea(layout: layout)
				}

				switch vm.phase {
				case .briefing:
					briefing
						.offset(y: overlayOffset)
				case .countdown(let value):
					countdown(value)
						.offset(y: overlayOffset)
				case .armed:
					armedHint
						.offset(y: overlayOffset)
				case .success:
					SniffResultOverlay(
						kind: .success, lineFrame: layout.boxFrame, analysis: vm.analysisVerdict,
						finishSeconds: vm.finishSeconds, pulls: vm.pullCount
					) {
						finish()
					} onRetry: {
						retry()
					}
				case .fail:
					SniffResultOverlay(
						kind: .fail, lineFrame: layout.boxFrame, analysis: nil, finishSeconds: nil
					) {
						finish()
					} onRetry: {
						retry()
					}
				}

				escapeLock
			}
		}
		.statusBarHidden(true)
		.persistentSystemOverlays(.hidden)
		.defersSystemGestures(on: .all)
		.onAppear {
			UIApplication.shared.isIdleTimerDisabled = true
			OrientationLock.lockToCurrent()
		}
		.onDisappear {
			UIApplication.shared.isIdleTimerDisabled = false
			OrientationLock.unlock()
		}
		.onChange(of: scenePhase) { _, newPhase in
			UIApplication.shared.isIdleTimerDisabled = (newPhase == .active)
		}
		.onChange(of: vm.phase) { _, newPhase in
			guard newPhase == .success || newPhase == .fail, !recorded else { return }
			recorded = true
			modelContext.insert(
				SniffSession(
					lineLengthCm: vm.lineLengthCm,
					withFriends: vm.withFriends,
					success: newPhase == .success,
					seconds: vm.finishSeconds ?? 0,
					pulls: vm.pullCount
				))
		}
	}

	// MARK: - Layout

	/// True-to-size layout along the screen's long axis: vertical in portrait,
	/// horizontal in landscape. Box length and width come from the physical
	/// cm/mm values via pointsPerCm; if the screen is shorter than the line,
	/// it is capped ("amtlich gekürzt"). The progress track runs parallel,
	/// offset by trackGap (portrait: left of the box, landscape: above it).
	private func lineLayout(in size: CGSize) -> LineLayout {
		let ppcm = Sniffonomics.pointsPerCm(displayScale: displayScale)
		let lengthPt = CGFloat(vm.lineLengthCm) * ppcm
		let boxThickness = max(6, CGFloat(vm.lineWidthMm) * ppcm / 10) + 16
		let portrait = size.height >= size.width

		if portrait {
			let available = size.height * 0.55
			let length = min(lengthPt, available)
			let box = CGRect(
				x: size.width / 2 + Self.trackGap / 2 - boxThickness / 2, y: size.height * 0.34,
				width: boxThickness, height: length)
			let track = CGRect(
				x: box.minX - Self.trackGap - Self.trackThickness / 2, y: box.minY,
				width: Self.trackThickness, height: length)
			return LineLayout(boxFrame: box, trackFrame: track, axis: .vertical, truncated: lengthPt > available)
		} else {
			let available = size.width * 0.72
			let length = min(lengthPt, available)
			let box = CGRect(
				x: (size.width - length) / 2, y: size.height * 0.6 - boxThickness / 2,
				width: length, height: boxThickness)
			let track = CGRect(
				x: box.minX, y: box.minY - Self.trackGap - Self.trackThickness / 2,
				width: length, height: Self.trackThickness)
			return LineLayout(boxFrame: box, trackFrame: track, axis: .horizontal, truncated: lengthPt > available)
		}
	}

	private func lineArea(layout: LineLayout) -> some View {
		ZStack {
			// tobacco box
			RoughRect(seed: 17, jitter: 2.5)
				.stroke(PaperColors.ink, lineWidth: 2.5)
				.frame(width: layout.boxFrame.width, height: layout.boxFrame.height)
				.position(x: layout.boxFrame.midX, y: layout.boxFrame.midY)

			if vm.phase == .briefing {
				Text("Tabak hier rein")
					.font(DoodleFont.hand(13))
					.foregroundStyle(PaperColors.pencil)
					.rotationEffect(layout.axis == .vertical ? .degrees(-90) : .degrees(-2))
					.position(x: layout.boxFrame.midX, y: layout.boxFrame.midY)
			}

			// progress track
			SegmentedLineView(
				covered: Set(0..<vm.clearedSegments),
				segments: SniffSessionViewModel.segmentCount,
				color: PaperColors.marker,
				axis: layout.axis
			)
			.frame(width: layout.trackFrame.width, height: layout.trackFrame.height)
			.position(x: layout.trackFrame.midX, y: layout.trackFrame.midY)

			// the shoveler follows the pull on the far side of the box
			if vm.isDetecting {
				TimelineView(.animation) { context in
					LineHelperDoodle()
						.frame(width: 64)
						.rotationEffect(
							.degrees(sin(context.date.timeIntervalSinceReferenceDate * 5) * 7))
				}
				.position(shovelerPosition(layout: layout))
				// a spring keeps its velocity when retargeted at mic rate
				.animation(.smooth(duration: 0.25), value: vm.progress)
			}

			if layout.axis == .vertical {
				NoseDoodle(crowned: false, fill: .clear)
					.frame(width: 26, height: 26)
					.position(x: layout.trackFrame.midX, y: layout.trackFrame.minY - 22)
				BuilderDoodle()
					.frame(width: 46)
					.position(x: layout.boxFrame.midX - 14, y: layout.boxFrame.minY - 34)
				ConeDoodle()
					.frame(width: 26)
					.position(x: layout.boxFrame.midX + 24, y: layout.boxFrame.minY - 26)
				ConeDoodle()
					.frame(width: 26)
					.position(x: layout.boxFrame.midX - 24, y: layout.boxFrame.maxY + 24)
				BuilderDoodle()
					.frame(width: 46)
					.scaleEffect(x: -1)
					.position(x: layout.boxFrame.midX + 14, y: layout.boxFrame.maxY + 34)
			} else {
				NoseDoodle(crowned: false, fill: .clear)
					.frame(width: 26, height: 26)
					.position(x: layout.trackFrame.minX - 24, y: layout.trackFrame.midY)
				BuilderDoodle()
					.frame(width: 46)
					.position(x: layout.boxFrame.minX - 38, y: layout.boxFrame.midY - 10)
				ConeDoodle()
					.frame(width: 26)
					.position(x: layout.boxFrame.minX - 30, y: layout.boxFrame.midY + 24)
				ConeDoodle()
					.frame(width: 26)
					.position(x: layout.boxFrame.maxX + 30, y: layout.boxFrame.midY + 24)
				BuilderDoodle()
					.frame(width: 46)
					.scaleEffect(x: -1)
					.position(x: layout.boxFrame.maxX + 38, y: layout.boxFrame.midY - 10)
			}
		}
	}

	private func shovelerPosition(layout: LineLayout) -> CGPoint {
		if layout.axis == .vertical {
			return CGPoint(
				x: layout.boxFrame.maxX + 44,
				y: layout.boxFrame.minY + layout.boxFrame.height * vm.progress
			)
		}
		return CGPoint(
			x: layout.boxFrame.minX + layout.boxFrame.width * vm.progress,
			y: layout.boxFrame.maxY + 44
		)
	}

	// MARK: - Phases

	private var briefing: some View {
		Button("Timer starten") { vm.start() }
			.buttonStyle(DoodleButtonStyle(color: PaperColors.marker))
	}

	private func countdown(_ value: Int) -> some View {
		ZStack {
			RoughCircle(seed: 9, jitter: 3)
				.stroke(PaperColors.ink, lineWidth: 4)

			TimelineView(.animation) { context in
				let fraction = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1)
				PieSliceShape(start: .degrees(-90), end: .degrees(-90 + 360 * fraction))
					.fill(PaperColors.ink.opacity(0.12))
			}

			RoughLine(seed: 4).stroke(PaperColors.ink.opacity(0.4), lineWidth: 1.5)
			RoughLine(seed: 6).stroke(PaperColors.ink.opacity(0.4), lineWidth: 1.5)
				.rotationEffect(.degrees(90))

			Text("\(value)")
				.font(DoodleFont.wordmark(96))
				.foregroundStyle(PaperColors.ink)
				.id(value)
				.transition(.scale.combined(with: .opacity))
		}
		.frame(width: 200, height: 200)
		.animation(AppAnimations.bouncy, value: value)
		.allowsHitTesting(false)
	}

	private var armedHint: some View {
		VStack(spacing: AppSpacing.lg) {
			Text("ZIEH!")
				.font(DoodleFont.wordmark(64))
				.foregroundStyle(PaperColors.marker)

			if let armedAt = vm.armedAt {
				TimelineView(.periodic(from: .now, by: 0.05)) { context in
					VStack(spacing: AppSpacing.lg) {
						Text(
							"⏱ \(max(0, context.date.timeIntervalSince(armedAt)).formatted(.number.precision(.fractionLength(1)))) s"
						)
						.font(DoodleFont.heading(24))
						.foregroundStyle(PaperColors.ink)
						.monospacedDigit()

						pullStatus(at: context.date)
					}
				}
			}
		}
		.multilineTextAlignment(.center)
		.allowsHitTesting(false)
	}

	@ViewBuilder
	private func pullStatus(at date: Date) -> some View {
		if vm.micFailed {
			Text("Mikro streikt 🎤\nSchloss halten zum Abbrechen")
				.font(DoodleFont.heading(18))
				.foregroundStyle(PaperColors.cross)
		} else if vm.isQuiet(at: date) {
			Text("Wir hören nix —\nkräftiger ziehen! 🔊")
				.font(DoodleFont.heading(20))
				.foregroundStyle(PaperColors.cross)
				.rotationEffect(.degrees(-4))
		} else if vm.isPulling(at: date) {
			Text("WÜRDIG 👃")
				.font(DoodleFont.heading(24))
				.foregroundStyle(PaperColors.check)
				.rotationEffect(.degrees(-6))
		} else if vm.progress > 0 {
			Text("Da liegt noch was —\nnachziehen! 👃")
				.font(DoodleFont.heading(20))
				.foregroundStyle(PaperColors.ink)
				.rotationEffect(.degrees(3))
		} else {
			Text("Kräftig durchs Röhrchen!")
				.font(DoodleFont.hand(17))
				.foregroundStyle(PaperColors.pencil)
		}
	}

	private var escapeLock: some View {
		VStack {
			Spacer()
			HStack {
				VStack(spacing: AppSpacing.xs) {
					Image(systemName: escapePressing ? "lock.open.fill" : "lock.fill")
						.font(.system(size: 24))
					Text("halten")
						.font(DoodleFont.hand(11))
				}
				.foregroundStyle(PaperColors.pencil.opacity(escapePressing ? 1 : 0.6))
				.scaleEffect(escapePressing ? 1.3 : 1)
				.animation(AppAnimations.quick, value: escapePressing)
				.padding(AppSpacing.xl)
				.contentShape(Rectangle())
				.onLongPressGesture(minimumDuration: 1.5) {
					vm.cancel()
					dismiss()
				} onPressingChanged: { pressing in
					escapePressing = pressing
				}
				Spacer()
			}
		}
	}

	// MARK: - Result Actions

	private func retry() {
		recorded = false
		vm.reset()
	}

	private func finish() {
		vm.cancel()
		dismiss()
	}
}

#Preview {
	SniffSessionView(
		lineLengthCm: 16, lineWidthMm: 5, withFriends: false, debugCapture: false)
}
