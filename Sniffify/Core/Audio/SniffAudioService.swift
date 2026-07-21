//
//  SniffAudioService.swift
//  Sniffify
//
//  Microphone sniff detector for the sniff session: taps the input node,
//  tracks a slow noise-floor EMA, and yields an event when the level spikes
//  sharply above it — a sharp nasal inhale outruns the floor, ambient noise
//  lifts the floor with it. Each event carries the buffer's zero-crossing
//  rate as a crude tube-vs-direct texture signal. Optionally writes the
//  whole detection window to a .caf for offline calibration (debug mode).
//  Consumed by SniffSessionViewModel.
//

import AVFoundation
import Foundation

final class SniffAudioService {
	struct SniffEvent {
		let peakDB: Float
		/// Zero-crossing rate 0...1 of the spiking buffer. A tube pull is
		/// more tonal/hissy (higher ZCR) than a broadband direct pull.
		let zcr: Float
	}

	// ponytail: global thresholds; real mics vary — these are the calibration
	// knobs (tune with Settings > Debug captures). The absolute minimum stops
	// quiet-room noise (floor −60) from spiking on any small sound.
	static let spikeThresholdDB: Float = 20
	static let minimumSpikeDB: Float = -32
	private static let debounce: TimeInterval = 0.8

	private let engine = AVAudioEngine()
	private var floorDB: Float = -60
	private var lastSpikeAt = Date.distantPast
	private var captureFile: AVAudioFile?

	/// When set before `events()`, every tapped buffer of the window is also
	/// written to this file (debug mode, for tuning thresholds offline).
	var captureURL: URL?

	/// Asks for record permission, returning whether the mic may be used.
	/// Denied is a supported path — the session then judges by touch alone.
	static func requestPermission() async -> Bool {
		switch AVAudioApplication.shared.recordPermission {
		case .granted:
			return true
		case .denied:
			return false
		case .undetermined:
			return await AVAudioApplication.requestRecordPermission()
		@unknown default:
			return false
		}
	}

	/// Starts the engine and yields detected sniff spikes. Terminating the
	/// stream (task cancellation) tears the engine down and closes capture.
	func events() -> AsyncStream<SniffEvent> {
		AsyncStream { continuation in
			let session = AVAudioSession.sharedInstance()
			// .playAndRecord so countdown ticks keep playing; .measurement
			// disables AGC so the RMS baseline is stable.
			try? session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
			try? session.setActive(true)

			let input = engine.inputNode
			let format = input.outputFormat(forBus: 0)

			if let url = captureURL {
				try? FileManager.default.createDirectory(
					at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
				captureFile = try? AVAudioFile(forWriting: url, settings: format.settings)
			}

			input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
				guard let self, let channel = buffer.floatChannelData?[0] else { return }
				let frames = Int(buffer.frameLength)
				guard frames > 0 else { return }

				try? self.captureFile?.write(from: buffer)

				var sum: Float = 0
				var crossings = 0
				var previous = channel[0]
				for i in 0..<frames {
					let sample = channel[i]
					sum += sample * sample
					if (sample >= 0) != (previous >= 0) {
						crossings += 1
					}
					previous = sample
				}
				let db = 20 * log10(max(sqrt(sum / Float(frames)), 1e-7))
				let zcr = Float(crossings) / Float(frames)

				let floor = self.floorDB
				self.floorDB = floor * 0.98 + db * 0.02
				let now = Date()
				if db > max(floor + Self.spikeThresholdDB, Self.minimumSpikeDB),
					now.timeIntervalSince(self.lastSpikeAt) > Self.debounce
				{
					self.lastSpikeAt = now
					continuation.yield(SniffEvent(peakDB: db, zcr: zcr))
				}
			}

			// resume after a call/Siri interruption ends, else the window
			// silently goes deaf
			let observer = NotificationCenter.default.addObserver(
				forName: AVAudioSession.interruptionNotification, object: session, queue: nil
			) { [weak self] note in
				guard
					let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
					AVAudioSession.InterruptionType(rawValue: raw) == .ended
				else { return }
				try? self?.engine.start()
			}

			// must be set BEFORE start(): the catch's finish() relies on it to
			// remove the tap, else the next installTap on bus 0 crashes
			continuation.onTermination = { [weak self] _ in
				NotificationCenter.default.removeObserver(observer)
				self?.engine.inputNode.removeTap(onBus: 0)
				self?.engine.stop()
				self?.captureFile = nil
				try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
			}

			do {
				try engine.start()
			} catch {
				continuation.finish()
				return
			}
		}
	}
}
