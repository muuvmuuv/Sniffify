//
//  NoseWallpaper.swift
//  Sniffify
//
//  Faint scattered crowned-nose pattern behind screen content, like the
//  sketch mockups' wallpaper.
//

import SwiftUI

struct NoseWallpaper: View {
	var rows = 6
	var columns = 4

	var body: some View {
		GeometryReader { proxy in
			let cellWidth = proxy.size.width / CGFloat(columns)
			let cellHeight = proxy.size.height / CGFloat(rows)
			ForEach(0..<(rows * columns), id: \.self) { index in
				let row = index / columns
				let column = index % columns
				var rng = SeededGenerator(seed: UInt64(index) &+ 77)
				let size = CGFloat.random(in: 26...44, using: &rng)
				let dx = CGFloat.random(in: -12...12, using: &rng)
				let dy = CGFloat.random(in: -10...10, using: &rng)
				let rotation = Double.random(in: -25...25, using: &rng)

				NoseDoodle(stroke: PaperColors.pencil, fill: .clear)
					.frame(width: size, height: size)
					.rotationEffect(.degrees(rotation))
					.position(
						x: cellWidth * (CGFloat(column) + 0.5) + dx,
						y: cellHeight * (CGFloat(row) + 0.5) + dy
					)
					.opacity(0.16)
			}
		}
		.allowsHitTesting(false)
	}
}

#Preview {
	ZStack {
		PaperBackground()
		NoseWallpaper()
	}
}
