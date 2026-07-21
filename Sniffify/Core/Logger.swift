//
//  Logger.swift
//  Sniffify
//
//  OSLog wrapper for structured logging.
//

import OSLog

/// App-wide logging categories.
enum Log {
	private static let subsystem = Bundle.main.bundleIdentifier ?? "Sniffify"

	static let general = Logger(subsystem: subsystem, category: "general")
	static let persistence = Logger(subsystem: subsystem, category: "persistence")
	static let network = Logger(subsystem: subsystem, category: "network")
	static let ui = Logger(subsystem: subsystem, category: "ui")
}
