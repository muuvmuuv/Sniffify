//
//  SniffAudioService.swift
//  Sniffify
//
//  Microphone plumbing for the sniff session: runs AVAudioEngine on its own
//  serial queue — activating the audio session and starting the engine block
//  for hundreds of milliseconds, far too long for the main thread mid-
//  countdown — and feeds every tapped buffer through SniffDetector.
//  Optionally writes the whole run to a .caf for offline calibration (debug
//  mode, replay with `just replay`). Consumed by SniffSessionViewModel.
//

import AVFoundation
import Foundation

/// Mic access for the sniff session: permission and the pull stream.
nonisolated enum SniffAudioService {
	/// Engines and the audio session are only touched here, so a quick cancel
	/// can't tear down before setup has finished, and one run's teardown can't
	/// deactivate the session under the next run's setup.
	private static let queue = DispatchQueue(label: "app.sniffify.audio", qos: .userInitiated)

	/// Asks for record permission, returning whether the mic may be used.
	/// Without it there is no session: a pull is only ever heard, never seen.
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

	/// Starts listening and yields every moment of detected pulling. Cancelling the
	/// consuming task tears the engine down and closes the capture; the
	/// stream only finishes on its own when the engine can't start (mic busy,
	/// no input).
	static func pulls(captureURL: URL? = nil) -> AsyncStream<SniffDetector.Pull> {
		AsyncStream { continuation in
			let queue = Self.queue
			nonisolated(unsafe) let engine = AVAudioEngine()
			let session = AVAudioSession.sharedInstance()

			// resume after a call/Siri interruption ends, else the window
			// silently goes deaf. iOS deactivates the session on interruption
			// begin, so it MUST be reactivated before the engine can restart.
			let observer = NotificationCenter.default.addObserver(
				forName: AVAudioSession.interruptionNotification, object: session, queue: nil
			) { note in
				guard
					let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
					AVAudioSession.InterruptionType(rawValue: raw) == .ended
				else { return }
				queue.async {
					try? session.setActive(true)
					try? engine.start()
				}
			}

			continuation.onTermination = { _ in
				NotificationCenter.default.removeObserver(observer)
				queue.async {
					engine.inputNode.removeTap(onBus: 0)
					engine.stop()
					try? session.setActive(false, options: .notifyOthersOnDeactivation)
				}
			}

			queue.async {
				// .playAndRecord so countdown ticks keep playing; .measurement
				// disables AGC so the level baseline is stable. iOS mutes haptics
				// and system sounds while recording unless explicitly allowed.
				try? session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
				try? session.setAllowHapticsAndSystemSoundsDuringRecording(true)
				try? session.setActive(true)

				let input = engine.inputNode
				let format = input.outputFormat(forBus: 0)
				let captureFile = captureURL.flatMap { url in
					try? FileManager.default.createDirectory(
						at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
					return try? AVAudioFile(forWriting: url, settings: format.settings)
				}
				var detector = SniffDetector(sampleRate: format.sampleRate)

				input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
					guard let channel = buffer.floatChannelData?[0] else { return }
					try? captureFile?.write(from: buffer)
					if let pull = detector.process(UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength)))
					{
						continuation.yield(pull)
					}
				}

				do {
					try engine.start()
				} catch {
					continuation.finish()
				}
			}
		}
	}
}
