//
//  SketchShapes.swift
//  Sniffify
//
//  Hand-drawn wobbly primitives (line, rect, circle) and the doodle button
//  style. Every screen builds its sketch look from these.
//

import SwiftUI

// MARK: - Seeded RNG

/// Deterministic LCG so the wobble is stable across redraws — jitter from
/// SystemRandomNumberGenerator would make shapes shimmer on every layout pass.
struct SeededGenerator: RandomNumberGenerator {
	private var state: UInt64

	init(seed: UInt64) {
		state = seed &+ 0x9E37_79B9_7F4A_7C15
	}

	mutating func next() -> UInt64 {
		state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
		return state
	}
}

extension CGFloat {
	static func jitter(_ amount: CGFloat, using rng: inout SeededGenerator) -> CGFloat {
		CGFloat.random(in: -amount...amount, using: &rng)
	}
}

// MARK: - Rough Shapes

/// Wobbly horizontal line across the rect's vertical center.
struct RoughLine: Shape {
	var seed: UInt64 = 1
	var jitter: CGFloat = 1.5

	func path(in rect: CGRect) -> Path {
		var rng = SeededGenerator(seed: seed)
		var path = Path()
		let steps = max(6, Int(rect.width / 14))
		var points: [CGPoint] = []
		for i in 0...steps {
			let x = rect.minX + rect.width * CGFloat(i) / CGFloat(steps)
			points.append(CGPoint(x: x, y: rect.midY + .jitter(jitter, using: &rng)))
		}
		path.addLines(points)
		return path
	}
}

/// Wobbly rectangle outline.
struct RoughRect: Shape {
	var seed: UInt64 = 2
	var jitter: CGFloat = 2

	func path(in rect: CGRect) -> Path {
		var rng = SeededGenerator(seed: seed)
		var path = Path()
		let corners = [
			CGPoint(x: rect.minX, y: rect.minY),
			CGPoint(x: rect.maxX, y: rect.minY),
			CGPoint(x: rect.maxX, y: rect.maxY),
			CGPoint(x: rect.minX, y: rect.maxY),
		]
		var points: [CGPoint] = []
		for i in 0..<4 {
			let from = corners[i]
			let to = corners[(i + 1) % 4]
			let length = hypot(to.x - from.x, to.y - from.y)
			let steps = max(3, Int(length / 20))
			for s in 0..<steps {
				let t = CGFloat(s) / CGFloat(steps)
				points.append(
					CGPoint(
						x: from.x + (to.x - from.x) * t + .jitter(jitter, using: &rng),
						y: from.y + (to.y - from.y) * t + .jitter(jitter, using: &rng)
					))
			}
		}
		points.append(points[0])
		path.addLines(points)
		return path
	}
}

/// Wobbly circle inscribed in the rect.
struct RoughCircle: Shape {
	var seed: UInt64 = 3
	var jitter: CGFloat = 2

	func path(in rect: CGRect) -> Path {
		var rng = SeededGenerator(seed: seed)
		var path = Path()
		let center = CGPoint(x: rect.midX, y: rect.midY)
		let radius = min(rect.width, rect.height) / 2 - jitter
		let steps = 40
		var points: [CGPoint] = []
		for i in 0...steps {
			let angle = CGFloat(i) / CGFloat(steps) * 2 * .pi
			let r = radius + .jitter(jitter, using: &rng)
			points.append(CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r))
		}
		path.addLines(points)
		return path
	}
}

// MARK: - Doodle Button

/// Hand-drawn button: handwriting label in a wobbly ink box on paper.
struct DoodleButtonStyle: ButtonStyle {
	var color: Color = PaperColors.ink

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(DoodleFont.heading(20))
			.foregroundStyle(color)
			.padding(.horizontal, AppSpacing.xxl)
			.padding(.vertical, AppSpacing.md)
			.background {
				RoughRect(seed: 11)
					.stroke(color, lineWidth: 2.5)
			}
			.scaleEffect(configuration.isPressed ? 0.93 : 1)
			.animation(AppAnimations.quick, value: configuration.isPressed)
	}
}
