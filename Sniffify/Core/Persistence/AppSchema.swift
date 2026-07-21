//
//  AppSchema.swift
//  Sniffify
//
//  SwiftData schema definition.
//

import SwiftData

/// All SwiftData models for the app.
enum AppSchema {
	static let models: [any PersistentModel.Type] = [
		SniffSession.self
	]
}
