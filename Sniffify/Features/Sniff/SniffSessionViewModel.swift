//
//  SniffSessionViewModel.swift
//  Sniffify
//
//  State machine for one locked sniff session: film countdown, a detection
//  window that opens shortly before zero, and the line clearing as the mic
//  hears the pull. Pulls go through a tube, which a touchscreen can't see —
//  so sound is the only input.
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

	static let segmentCount = 20
	/// Opens detection this long before zero, so a slightly early pull counts.
	static let windowPadding: TimeInterval = 1.5
	/// The challenge never stops on a botched pull — but after this long the
	/// construction site closes.
	static let challengeTimeout: TimeInterval = 45
	/// Nothing heard for this long since zero or the last pull: nudge.
	static let quietHint: TimeInterval = 3
	// ponytail: pure guess until debug captures exist; calibrate with real
	// tube vs. direct recordings from Settings > Debug.
	static let tubeZCRThreshold: Float = 0.25

	private(set) var phase: Phase = .briefing
	/// 0...1 share of the line pulled so far; dashes vanish from the start
	/// and the shoveler follows.
	private(set) var progress: Double = 0
	private(set) var isDetecting = false
	/// Last moment the mic heard pulling.
	private(set) var lastHeardAt: Date?
	/// Separate attempts it took; every extra one costs a grade.
	private(set) var pullCount = 0
	/// The engine couldn't start — nothing can be heard this session.
	private(set) var micFailed = false
	/// Set when the countdown hits zero; drives the challenge stopwatch.
	private(set) var armedAt: Date?
	/// Seconds from zero to a completed line (0 for early finishers).
	private(set) var finishSeconds: Double?

	let lineLengthCm: Double
	let lineWidthMm: Double
	let withFriends: Bool
	let debugCapture: Bool

	private var pulledSeconds: TimeInterval = 0
	/// Pull-time-weighted ZCR sum, for the texture verdict.
	private var zcrSum: Float = 0
	private var runTask: Task<Void, Never>?
	private var audioTask: Task<Void, Never>?
	private var timeoutTask: Task<Void, Never>?

	init(lineLengthCm: Double, lineWidthMm: Double, withFriends: Bool, debugCapture: Bool = false) {
		self.lineLengthCm = lineLengthCm
		self.lineWidthMm = lineWidthMm
		self.withFriends = withFriends
		self.debugCapture = debugCapture
	}

	var clearedSegments: Int {
		Int(progress * Double(Self.segmentCount))
	}

	/// The mic heard pulling just now.
	func isPulling(at date: Date) -> Bool {
		lastHeardAt.map { date.timeIntervalSince($0) < 0.3 } ?? false
	}

	/// Armed, but nothing heard for `quietHint` since zero or the last pull.
	func isQuiet(at date: Date) -> Bool {
		guard phase == .armed, let armedAt else { return false }
		return date.timeIntervalSince(max(armedAt, lastHeardAt ?? armedAt)) > Self.quietHint
	}

	/// Comedic acoustic classification of the whole pull.
	var analysisVerdict: String? {
		guard pulledSeconds > 0 else { return nil }
		return zcrSum / Float(pulledSeconds) > Self.tubeZCRThreshold
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
		startListening()
		runTask = Task { await run() }
	}

	func reset() {
		cancel()
		phase = .briefing
		progress = 0
		pulledSeconds = 0
		zcrSum = 0
		lastHeardAt = nil
		pullCount = 0
		micFailed = false
		armedAt = nil
		finishSeconds = nil
	}

	func cancel() {
		runTask?.cancel()
		audioTask?.cancel()
		timeoutTask?.cancel()
		isDetecting = false
	}

	/// Countdown on fixed deadlines, so ticks never drift: "3" at 0 s … "0"
	/// (armed) at 3 s. Detection opens windowPadding before zero and then
	/// STAYS open: a botched pull doesn't fail, the stopwatch just runs until
	/// the line is gone — or the challengeTimeout closes the site.
	private func run() async {
		let zero = ContinuousClock.now + .seconds(3)
		/// Sleeps until `seconds` before zero; false once cancelled.
		func reach(_ seconds: Double) async -> Bool {
			try? await Task.sleep(until: zero - .seconds(seconds))
			return !Task.isCancelled
		}

		phase = .countdown(3)
		Feedback.tick()
		guard await reach(2) else { return }
		phase = .countdown(2)
		Feedback.tick()
		guard await reach(Self.windowPadding) else { return }
		isDetecting = true
		guard await reach(1) else { return }
		phase = .countdown(1)
		Feedback.tick()
		guard await reach(0) else { return }
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
		if phase == .armed, progress >= 1 {
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

	/// The mic starts with the countdown, so the noise floor has settled by
	/// the time detection opens; pulls heard before that are ignored. Keeps
	/// consuming until the verdict so a debug capture spans the whole run.
	private func startListening() {
		let stamp = Date.now.formatted(
			.iso8601.year().month().day().timeSeparator(.omitted).time(includingFractionalSeconds: false))
		let captureURL = debugCapture ? Self.capturesDirectory.appending(path: "sniff-\(stamp).caf") : nil
		let requiredSeconds = lineLengthCm * Sniffonomics.pullSecondsPerCm
		audioTask = Task {
			for await pull in SniffAudioService.pulls(captureURL: captureURL) where isDetecting {
				// a pull already running when detection opened counts too
				if pull.startsPull || pullCount == 0 {
					pullCount += 1
				}
				pulledSeconds += pull.seconds
				zcrSum += pull.zcr * Float(pull.seconds)
				lastHeardAt = .now
				progress = min(1, pulledSeconds / requiredSeconds)
				checkCompletion()
			}
			// stream ended without being cancelled = engine never ran
			// (mic busy, start failure)
			if !Task.isCancelled {
				micFailed = true
			}
		}
	}
}
