//
//  sniff-replay.swift
//  Sniffify
//
//  Offline calibration for the pull detector: replays debug captures
//  (Settings > Debug > Sniff-Aufnahmen, .caf) through the app's own
//  SniffDetector and prints a level timeline, the heard pulling time and
//  how many cm of line it would clear. Without arguments it runs a
//  synthetic self-check instead. Run via `just replay [files…]`.
//

import AVFoundation

@main
enum SniffReplay {
	static func main() throws {
		let paths = CommandLine.arguments.dropFirst()
		if paths.isEmpty {
			selfCheck()
		}
		for path in paths {
			try replay(URL(filePath: path))
		}
	}

	/// Prints one row per 0.1 s: loudest broadband buffer (how loud the room
	/// is), loudest hiss-band buffer, its floor, mean unfiltered ZCR, pulled
	/// time so far, and a hiss meter from −80 to 0 dB with the trigger
	/// marked `|`.
	static func replay(_ url: URL) throws {
		let file = try AVAudioFile(forReading: url)
		let format = file.processingFormat
		guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024) else { return }
		var detector = SniffDetector(sampleRate: format.sampleRate)
		var elapsed: TimeInterval = 0
		var pulled: TimeInterval = 0
		var pulls = 0
		var nextRow: TimeInterval = 0.1
		var loudest = -Float.infinity
		var loudestRoom = -Float.infinity
		var zcrs: [Float] = []

		print("\n\(url.lastPathComponent) — \(Int(format.sampleRate)) Hz")
		print("  time    room    hiss   floor   zcr  pulled")
		while file.framePosition < file.length {
			try file.read(into: buffer, frameCount: 1024)
			guard let channel = buffer.floatChannelData?[0], buffer.frameLength > 0 else { break }
			if let pull = detector.process(UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength))) {
				pulled += pull.seconds
				if pull.startsPull {
					pulls += 1
					print(String(format: "   👃 pull %d starts at %.2f s", pulls, pull.at))
				}
			}
			let level = detector.lastLevel
			let duration = Double(buffer.frameLength) / format.sampleRate
			let samples = UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength))
			let room = 10 * log10(max(samples.reduce(0) { $0 + $1 * $1 } / Float(samples.count), 1e-14))
			loudestRoom = max(loudestRoom, room)
			loudest = max(loudest, level.db)
			zcrs.append(level.zcr)
			elapsed += duration
			if elapsed >= nextRow {
				let zcr = zcrs.reduce(0, +) / Float(zcrs.count)
				print(
					String(
						format: "%6.2f s %6.1f  %6.1f  %6.1f  %.2f  %5.2f s  ", elapsed, loudestRoom, loudest,
						detector.floorDB, zcr, pulled
					)
						+ meter(loudest, trigger: detector.triggerDB))
				loudest = -.infinity
				loudestRoom = -.infinity
				zcrs = []
				nextRow += 0.1
			}
		}
		print(
			String(
				format: "  → %.2f s pulled in %d pulls = %.1f cm of line (at %.2f s/cm)", pulled, pulls,
				pulled / Sniffonomics.pullSecondsPerCm, Sniffonomics.pullSecondsPerCm))
	}

	static func meter(_ db: Float, trigger: Float) -> String {
		let width = 40
		func cell(_ db: Float) -> Int { min(width, max(0, Int((db + 80) / 2))) }
		var cells = Array(repeating: Character(" "), count: width)
		for index in 0..<cell(db) {
			cells[index] = "█"
		}
		if cell(trigger) < width {
			cells[cell(trigger)] = "|"
		}
		return String(cells)
	}

	/// Synthetic scene of white noise (RMS ≈ amplitude/√3, all bands) and a
	/// 220 Hz tone standing in for a voice (no hiss band): the bump, tick,
	/// fricative and voice must add no pulling time; each pull its full
	/// length — also the one drowned by a voice twice as loud.
	static func selfCheck() {
		let rate = 48_000.0
		let frames = 1024
		let bufferDuration = Double(frames) / rate
		let scene: [(name: String, seconds: TimeInterval, noise: Float, voice: Float)] = [
			("room", 1.0, 0.0005, 0),  // ≈ −71 dB
			("bump", 0.02, 0.3, 0),  // one loud buffer, ≈ −15 dB
			("room", 0.5, 0.0005, 0),
			("tick", 0.05, 0.1, 0),
			("room", 0.5, 0.0005, 0),
			("fricative", 0.15, 0.05, 0),  // a long „sch"
			("room", 0.5, 0.0005, 0),
			("voice", 0.8, 0.0005, 0.05),  // ≈ −29 dB
			("room", 0.5, 0.0005, 0),
			("soft pull", 0.4, 0.006, 0),  // ≈ −49 dB
			("room", 0.5, 0.0005, 0),
			("firm pull", 0.8, 0.05, 0),
			("room", 0.5, 0.0005, 0),
			("pull under voice", 0.8, 0.02, 0.1),  // pull ≈ −39 dB, voice ≈ −23 dB
			("room", 0.5, 0.0005, 0),
		]

		var detector = SniffDetector(sampleRate: rate)
		var pulled: [String: TimeInterval] = [:]
		var attempts = 0
		var frame = 0
		for part in scene {
			let buffers = max(1, Int((part.seconds / bufferDuration).rounded()))
			for _ in 0..<buffers {
				let samples = (0..<frames).map { _ in
					frame += 1
					return Float.random(in: -part.noise...part.noise)
						+ part.voice * sin(2 * .pi * 220 * Float(frame) / Float(rate))
				}
				if let pull = samples.withUnsafeBufferPointer({ detector.process($0) }) {
					pulled[part.name, default: 0] += pull.seconds
					attempts += pull.startsPull ? 1 : 0
				}
			}
			if part.name.contains("pull") {
				let heard = pulled[part.name] ?? 0
				precondition(
					abs(heard - Double(buffers) * bufferDuration) < bufferDuration * 1.5,
					"\(part.name): heard \(heard) s of \(part.seconds) s")
			}
		}
		precondition(
			pulled.keys.sorted() == ["firm pull", "pull under voice", "soft pull"],
			"only the pulls may count, got \(pulled)")
		precondition(attempts == 3, "three separate pulls, counted \(attempts)")

		// the Zeugnis: capture …T214625 (1 pull too weak + 1 more, done 6.3 s
		// after zero) earns a 4
		for (pulls, seconds, expected) in [(1, 0.8, 1), (1, 2.1, 2), (2, 6.3, 4), (9, 40.0, 6)] {
			let grade = Sniffonomics.grade(pulls: pulls, seconds: seconds)
			precondition(grade == expected, "\(pulls) pulls in \(seconds) s: grade \(grade), expected \(expected)")
		}
		print(
			String(
				format:
					"self-check passed: pulls heard %.2f / %.2f / %.2f s (soft / firm / under a louder voice) as 3 attempts; bump, tick, fricative and voice ignored; grades OK",
				pulled["soft pull"] ?? 0, pulled["firm pull"] ?? 0, pulled["pull under voice"] ?? 0))
	}
}
