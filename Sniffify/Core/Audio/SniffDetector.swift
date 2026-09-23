//
//  SniffDetector.swift
//  Sniffify
//
//  The pull recognizer, free of any AVFoundation plumbing so the offline
//  replay (`just replay`) runs the exact same code: mic samples in, pulling
//  time out. A pull is airflow hiss, so only the band above `hissCutoffHz`
//  is measured — voices and bar chatter live far below it, which keeps them
//  out even when they are louder than the pull. Within that band a pull is
//  a SUSTAINED rise above the noise floor: German fricatives („sch", „s"),
//  bumps and countdown ticks never last `minDuration`.
//  Fed by SniffAudioService.
//

import Foundation

/// Stateful pull recognizer: tracks the hiss band's noise floor and, once
/// the level has stayed well above it for `minDuration`, reports every
/// moment of pulling as it happens.
nonisolated struct SniffDetector {
	struct Pull {
		/// Seconds since listening started when this stretch began.
		let at: TimeInterval
		/// Pulling time this buffer adds: the whole stretch so far on the
		/// buffer where a pull first qualifies, then each buffer's own length.
		let seconds: TimeInterval
		/// Mean zero-crossing rate 0...1 of the unfiltered signal over those
		/// seconds — the tube-vs-direct texture hint.
		let zcr: Float
		/// First report of a new attempt, not a continuation after a breath.
		let startsPull: Bool
	}

	/// One buffer's hiss-band loudness (RMS in dBFS) and the unfiltered
	/// zero-crossing rate.
	struct Level {
		let db: Float
		let zcr: Float
	}

	// ponytail: calibration knobs, tuned on the first device capture (direct
	// pulls, quiet room) mixed with synthetic 5-voice German bar babble
	// (2026-09-23): full pulls keep ≥ 0.75 s of credit up to −40 dBFS babble
	// with zero false pulls; from −35 dBFS the pull drowns. Re-check real
	// captures (tube pulls, a real bar, music) with `just replay`.
	static let hissCutoffHz: Double = 5000
	static let thresholdDB: Float = 12
	/// Keeps a near-silent room from turning every rustle into a pull.
	static let minimumDB: Float = -65
	static let minDuration: TimeInterval = 0.2
	/// Dips shorter than this don't split one pull into two.
	static let gapTolerance: TimeInterval = 0.06
	/// Pauses shorter than this are one pull catching breath; longer ones
	/// start a new attempt (and cost a grade).
	static let pullGap: TimeInterval = 0.3
	/// After the engine starts the floor just follows the input.
	static let warmUp: TimeInterval = 0.25

	private struct Burst {
		var above: TimeInterval = 0
		var below: TimeInterval = 0
		var qualified = false
		var zcrSum: Float = 0
		var buffers = 0
	}

	/// Second-order high-pass (RBJ cookbook biquad), state carried across
	/// buffers.
	private struct HighPass {
		let b0, b1, b2, a1, a2: Float
		var x1: Float = 0, x2: Float = 0, y1: Float = 0, y2: Float = 0

		init(cutoff: Double, sampleRate: Double) {
			let w0 = 2 * Double.pi * cutoff / sampleRate
			let alpha = sin(w0) / (2 * 0.7071)
			let a0 = 1 + alpha
			b0 = Float((1 + cos(w0)) / 2 / a0)
			b1 = Float(-(1 + cos(w0)) / a0)
			b2 = b0
			a1 = Float(-2 * cos(w0) / a0)
			a2 = Float((1 - alpha) / a0)
		}

		mutating func callAsFunction(_ x: Float) -> Float {
			let y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
			x2 = x1
			x1 = x
			y2 = y1
			y1 = y
			return y
		}
	}

	let sampleRate: Double
	private(set) var floorDB: Float = -80
	/// The most recent buffer's measurement, for the replay's timeline.
	private(set) var lastLevel = Level(db: -140, zcr: 0)
	private var hiss: HighPass
	private var elapsed: TimeInterval = 0
	private var burst = Burst()
	/// End of the last reported pulling, to tell a breath from a new attempt.
	private var lastPulledAt = -TimeInterval.infinity

	init(sampleRate: Double) {
		self.sampleRate = sampleRate
		hiss = HighPass(cutoff: Self.hissCutoffHz, sampleRate: sampleRate)
	}

	/// The hiss-band level a buffer must beat to count as pulling.
	var triggerDB: Float { max(floorDB + Self.thresholdDB, Self.minimumDB) }

	/// Feeds one mono buffer; returns the pulling time it adds, if any.
	mutating func process(_ samples: UnsafeBufferPointer<Float>) -> Pull? {
		guard !samples.isEmpty else { return nil }
		let level = measure(samples)
		lastLevel = level
		let duration = Double(samples.count) / sampleRate
		defer { elapsed += duration }
		if elapsed < Self.warmUp {
			floorDB = elapsed == 0 ? level.db : floorDB + (level.db - floorDB) * 0.3
			return nil
		}

		let above = level.db > triggerDB
		// the floor sinks fast but rises slowly: a pull barely lifts it,
		// lasting ambient noise (music, a hood fan) does within seconds
		floorDB += (level.db - floorDB) * (level.db < floorDB ? 0.1 : 0.005)

		guard above else {
			burst.below += duration
			if burst.below > Self.gapTolerance {
				burst = Burst()
			}
			return nil
		}
		burst.below = 0
		burst.above += duration
		if burst.qualified {
			lastPulledAt = elapsed + duration
			return Pull(at: elapsed, seconds: duration, zcr: level.zcr, startsPull: false)
		}
		burst.zcrSum += level.zcr
		burst.buffers += 1
		guard burst.above >= Self.minDuration else { return nil }
		burst.qualified = true
		let start = elapsed + duration - burst.above
		defer { lastPulledAt = elapsed + duration }
		return Pull(
			at: start, seconds: burst.above, zcr: burst.zcrSum / Float(burst.buffers),
			startsPull: start - lastPulledAt > Self.pullGap)
	}

	/// Hiss-band loudness and unfiltered zero-crossing rate of one buffer.
	private mutating func measure(_ samples: UnsafeBufferPointer<Float>) -> Level {
		var sum: Float = 0
		var crossings = 0
		var previous = samples[0]
		for sample in samples {
			let filtered = hiss(sample)
			sum += filtered * filtered
			if (sample >= 0) != (previous >= 0) {
				crossings += 1
			}
			previous = sample
		}
		let rms = (sum / Float(samples.count)).squareRoot()
		return Level(db: 20 * log10(max(rms, 1e-7)), zcr: Float(crossings) / Float(samples.count))
	}
}
