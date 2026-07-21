//
//  TouchLineOverlay.swift
//  Sniffify
//
//  UIKit touch plumbing for the sniff session: raw multi-touch points with
//  UITouch.majorRadius (SwiftUI gestures expose neither).
//

import SwiftUI
import UIKit

// MARK: - Touch Reporting

struct TrackTouch {
	let point: CGPoint
	let radius: CGFloat
}

final class TouchReportingView: UIView {
	var onTouches: (([TrackTouch]) -> Void)?

	override init(frame: CGRect) {
		super.init(frame: frame)
		isMultipleTouchEnabled = true
		backgroundColor = .clear
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError("unused") }

	private func report(_ event: UIEvent?) {
		let touches = (event?.allTouches ?? []).filter { $0.phase != .ended && $0.phase != .cancelled }
		onTouches?(touches.map { TrackTouch(point: $0.location(in: self), radius: $0.majorRadius) })
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { report(event) }
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { report(event) }
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { report(event) }
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { report(event) }
}

/// Full-surface touch tracker; reports every active touch with its contact
/// radius (a nose flat on glass is much wider than a finger).
struct TouchLineOverlay: UIViewRepresentable {
	var onTouches: ([TrackTouch]) -> Void

	func makeUIView(context: Context) -> TouchReportingView {
		let view = TouchReportingView()
		view.onTouches = onTouches
		return view
	}

	func updateUIView(_ uiView: TouchReportingView, context: Context) {
		uiView.onTouches = onTouches
	}
}
