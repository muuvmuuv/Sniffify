//
//  SegmentedLineView.swift
//  Sniffify
//
//  The hand-drawn dashed "line": fat wobbly dashes marked out like a
//  construction site. Covered dashes fade out, so it doubles as the live
//  coverage display while sniffing.
//

import SwiftUI

struct SegmentedLineView: View {
	var covered: Set<Int> = []
	var segments = 20
	var color = PaperColors.ink
	var axis: Axis = .horizontal

	var body: some View {
		GeometryReader { proxy in
			let gap: CGFloat = 6
			let length = axis == .horizontal ? proxy.size.width : proxy.size.height
			let dashLength = max(2, (length - gap * CGFloat(segments - 1)) / CGFloat(segments))
			let layout =
				axis == .horizontal
				? AnyLayout(HStackLayout(spacing: gap)) : AnyLayout(VStackLayout(spacing: gap))
			layout {
				ForEach(0..<segments, id: \.self) { index in
					dash(index: index)
						.frame(
							width: axis == .horizontal ? dashLength : nil,
							height: axis == .horizontal ? nil : dashLength
						)
				}
			}
			.frame(width: proxy.size.width, height: proxy.size.height)
		}
	}

	private func dash(index: Int) -> some View {
		var rng = SeededGenerator(seed: UInt64(index) &+ 5)
		let rotation = Double.random(in: -5...5, using: &rng)
		return Capsule()
			.fill(color.opacity(0.9))
			.rotationEffect(.degrees(rotation))
			.opacity(covered.contains(index) ? 0 : 1)
			.animation(AppAnimations.quick, value: covered.contains(index))
	}
}

#Preview {
	ZStack {
		PaperBackground()
		SegmentedLineView(covered: [3, 4, 5])
			.frame(width: 320, height: 14)
	}
}
