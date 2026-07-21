//
//  Feedback.swift
//  Sniffify
//
//  Haptic + system-sound moments for the sniff session.
//

import AudioToolbox
import UIKit

enum Feedback {
	/// Countdown tick: rigid tap + keyboard tock.
	static func tick() {
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
		AudioServicesPlaySystemSound(1104)
	}

	static func success() {
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}

	static func failure() {
		UINotificationFeedbackGenerator().notificationOccurred(.error)
	}
}
