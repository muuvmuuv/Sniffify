//
//  SniffSession.swift
//  Sniffify
//
//  One sniff attempt. Successful sessions feed the Bestenliste totals and
//  the Wrapped year recap; failures are kept for the sad statistics.
//

import Foundation
import SwiftData

@Model
final class SniffSession {
	var id: UUID
	var date: Date
	var lineLengthCm: Double
	var withFriends: Bool
	var success: Bool
	/// Challenge time: seconds from countdown zero to the finished line.
	var seconds: Double = 0

	init(date: Date = .now, lineLengthCm: Double, withFriends: Bool, success: Bool, seconds: Double = 0) {
		self.id = UUID()
		self.date = date
		self.lineLengthCm = lineLengthCm
		self.withFriends = withFriends
		self.success = success
		self.seconds = seconds
	}
}
