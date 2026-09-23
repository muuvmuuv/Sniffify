//
//  SniffSession.swift
//  Sniffify
//
//  One sniff attempt. Successful sessions feed the Bestenliste totals and
//  the Wrapped year recap; failures are kept for the sad statistics — and
//  drag the Notendurchschnitt down as a 6.
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
	/// Separate attempts it took to clear the line (1 for sessions recorded
	/// before attempts were counted).
	var pulls: Int = 1

	init(
		date: Date = .now, lineLengthCm: Double, withFriends: Bool, success: Bool, seconds: Double = 0,
		pulls: Int = 1
	) {
		self.id = UUID()
		self.date = date
		self.lineLengthCm = lineLengthCm
		self.withFriends = withFriends
		self.success = success
		self.seconds = seconds
		self.pulls = pulls
	}

	/// Amtliche Schulnote 1…6; a line that was never finished is a 6.
	var grade: Int {
		success ? Sniffonomics.grade(pulls: pulls, seconds: seconds) : 6
	}
}

extension Collection<SniffSession> {
	/// Notendurchschnitt over these sessions; nil when there are none.
	var averageGrade: Double? {
		isEmpty ? nil : Double(reduce(0) { $0 + $1.grade }) / Double(count)
	}
}
