//
//  SniffSessionViewModel.swift
//  Sniffify
//
//  State machine for one locked sniff session: film countdown, a detection
//  window around zero, and the audio + touch fusion verdict. The line runs
//  along the screen's long axis; coverage follows whichever axis the
//  lineFrame is oriented on.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class SniffSessionViewModel {
	enum Phase: Equatable {
		case briefing
		case countdown(Int)
		case armed
		case success
		case fail
	}

	enum TouchVerdict: Equatable {
		case none
		case finger
		case nose
	}

	static let segmentCount = 20
	// The line must be COMPLETELY gone — the remaining dashes on screen are
	// the visible to-do list. Audio is only the anti-cheat gate on top.
	static let coverageThreshold = 1.0
	// ponytail: tuning knobs — how fat a touch must be to count as a nose,
	// and the window around zero.
	static let noseRadiusThreshold: CGFloat = 45
	static let windowPadding: TimeInterval = 1.5
	/// Finishing within this after zero counts as "perfekt".
	static let perfectTime: TimeInterval = 1.5
	/// The challenge never stops on a botched pull — but after this long the
	/// construction site closes.
	static let challengeTimeout: TimeInterval = 45
	// ponytail: pure guess until debug captures exist; calibrate with real
	// tube vs. direct recordings from Settings > Debug.
	static let tubeZCRThreshold: Float = 0.25

	private(set) var phase: Phase = .briefing
	private(set) var touchVerdict: TouchVerdict = .none
	private(set) var coveredSegments: Set<Int> = []
	private(set) var isDetecting = false
	private(set) var lastEvent: SniffAudioService.SniffEvent?
	/// Set when the countdown hits zero; drives the challenge stopwatch.
	private(set) var armedAt: Date?
	/// Seconds from zero to a completed line (0 for early finishers).
	private(set) var finishSeconds: Double?

	/// The dashed line's frame in the session's full-screen coordinate space;
	/// set by the view, consumed by the coverage math. Orientation is derived
	/// from its aspect (taller than wide = vertical line).
	var lineFrame: CGRect = .zero

	let lineLengthCm: Double
	let lineWidthMm: Double
	let withFriends: Bool
	let micAuthorized: Bool
	let debugCapture: Bool

	private var sawSpike = false
	private var audioFailed = false
	private var runTask: Task<Void, Never>?
	private var audioTask: Task<Void, Never>?
	private var timeoutTask: Task<Void, Never>?
	private let audio = SniffAudioService()

	init(
		lineLengthCm: Double, lineWidthMm: Double, withFriends: Bool, micAuthorized: Bool,
		debugCapture: Bool = false
	) {
		self.lineLengthCm = lineLengthCm
		self.lineWidthMm = lineWidthMm
		self.withFriends = withFriends
		self.micAuthorized = micAuthorized
		self.debugCapture = debugCapture
	}

	var coverage: Double {
		Double(coveredSegments.count) / Double(Self.segmentCount)
	}

	/// Comedic acoustic classification, only meaningful after a spike.
	var analysisVerdict: String? {
		guard let event = lastEvent else { return nil }
		return event.zcr > Self.tubeZCRThreshold
			? "Analyse: Röhrchen erkannt 🥤"
			: "Analyse: Direktzug, respektvoll klassisch 👃"
	}

	// MARK: - Debug Captures

	static var capturesDirectory: URL {
		URL.documentsDirectory.appending(path: "SniffCaptures")
	}

	// MARK: - Flow

	func start() {
		guard phase == .briefing else { return }
		runTask = Task { await run() }
	}

	func reset() {
		runTask?.cancel()
		audioTask?.cancel()
		timeoutTask?.cancel()
		phase = .briefing
		touchVerdict = .none
		coveredSegments = []
		sawSpike = false
		audioFailed = false
		lastEvent = nil
		armedAt = nil
		finishSeconds = nil
		isDetecting = false
	}

	func cancel() {
		runTask?.cancel()
		audioTask?.cancel()
		timeoutTask?.cancel()
		isDetecting = false
	}

	/// Countdown timeline: 0 s "5" … 5 s "0"/armed. Detection opens
	/// windowPadding before zero (a slightly early pull counts) and then
	/// STAYS open: a botched pull doesn't fail, the stopwatch just runs
	/// until the line is finished — or the challengeTimeout closes the site.
	private func run() async {
		for value in [5, 4, 3] {
			phase = .countdown(value)
			Feedback.tick()
			try? await Task.sleep(for: .seconds(1))
			if Task.isCancelled { return }
		}
		phase = .countdown(2)
		Feedback.tick()
		try? await Task.sleep(for: .seconds(1 - Self.windowPadding + 1))
		if Task.isCancelled { return }
		openDetection()
		try? await Task.sleep(for: .seconds(Self.windowPadding - 1))
		if Task.isCancelled { return }
		phase = .countdown(1)
		Feedback.tick()
		try? await Task.sleep(for: .seconds(1))
		if Task.isCancelled { return }
		phase = .armed
		Feedback.tick()
		armedAt = .now
		checkCompletion()
		timeoutTask = Task {
			try? await Task.sleep(for: .seconds(Self.challengeTimeout))
			if !Task.isCancelled {
				finish(success: false)
			}
		}
	}

	private func checkCompletion() {
		guard phase == .armed else { return }
		let audioUsable = micAuthorized && !audioFailed
		if coverage >= Self.coverageThreshold, !audioUsable || sawSpike {
			finish(success: true)
		}
	}

	private func finish(success: Bool) {
		guard phase == .armed else { return }
		audioTask?.cancel()
		timeoutTask?.cancel()
		isDetecting = false
		if success {
			finishSeconds = max(0, Date.now.timeIntervalSince(armedAt ?? .now))
		}
		phase = success ? .success : .fail
		success ? Feedback.success() : Feedback.failure()
	}

	private func openDetection() {
		coveredSegments = []
		sawSpike = false
		lastEvent = nil
		isDetecting = true
		guard micAuthorized else { return }
		if debugCapture {
			let stamp = Date.now.formatted(
				.iso8601.year().month().day().timeSeparator(.omitted).time(includingFractionalSeconds: false))
			audio.captureURL = Self.capturesDirectory.appending(path: "sniff-\(stamp).caf")
		}
		// keep consuming until the window closes so debug capture spans the
		// whole window and the last spike wins the texture analysis
		audioFailed = false
		audioTask = Task { [audio] in
			for await event in audio.events() {
				sawSpike = true
				lastEvent = event
				checkCompletion()
			}
			// stream ended without being cancelled = engine never ran
			// (mic busy, start failure) -> judge by touch alone
			if !Task.isCancelled {
				audioFailed = true
				checkCompletion()
			}
		}
	}

	// MARK: - Touch Input

	/// Coverage treats each touch as a CIRCLE, not a point: a nose's contact
	/// area reaches the track even when its centroid sits off to the side,
	/// and one fat contact covers a span of segments, not just one.
	func handleTouches(_ touches: [TrackTouch]) {
		guard isDetecting else { return }

		let maxRadius = touches.map(\.radius).max() ?? 0
		if maxRadius >= Self.noseRadiusThreshold {
			touchVerdict = .nose
		} else if maxRadius > 0, touchVerdict == .none {
			touchVerdict = .finger
		}

		guard lineFrame != .zero else { return }
		let horizontal = lineFrame.width >= lineFrame.height
		let length = horizontal ? lineFrame.width : lineFrame.height
		let band = (horizontal ? lineFrame.height : lineFrame.width) / 2 + 30
		let n = Self.segmentCount

		for touch in touches {
			let offAxis =
				horizontal
				? abs(touch.point.y - lineFrame.midY) : abs(touch.point.x - lineFrame.midX)
			guard offAxis <= band + touch.radius else { continue }
			let tCenter =
				horizontal
				? (touch.point.x - lineFrame.minX) / length
				: (touch.point.y - lineFrame.minY) / length
			let tSpread = touch.radius / length
			guard tCenter + tSpread >= 0, tCenter - tSpread <= 1 else { continue }
			let low = max(0, Int(((tCenter - tSpread) * CGFloat(n)).rounded(.down)))
			let high = min(n - 1, Int(((tCenter + tSpread) * CGFloat(n)).rounded(.down)))
			for segment in low...high {
				coveredSegments.insert(segment)
			}
		}

		checkCompletion()
	}
}
