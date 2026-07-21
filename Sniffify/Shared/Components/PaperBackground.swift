//
//  PaperBackground.swift
//  Sniffify
//
//  The crumpled-paper canvas behind every screen: warm paper color, faint
//  procedural creases, and a soft vignette.
//

import SwiftUI

struct PaperBackground: View {
	var body: some View {
		ZStack {
			PaperColors.paper

			Canvas { context, size in
				var rng = SeededGenerator(seed: 42)
				for _ in 0..<38 {
					var path = Path()
					var point = CGPoint(
						x: CGFloat.random(in: -60...size.width + 60, using: &rng),
						y: CGFloat.random(in: -60...size.height + 60, using: &rng)
					)
					path.move(to: point)
					for _ in 0..<3 {
						point.x += CGFloat.random(in: -160...160, using: &rng)
						point.y += CGFloat.random(in: -160...160, using: &rng)
						path.addLine(to: point)
					}
					context.stroke(path, with: .color(.black.opacity(0.03)), lineWidth: 0.8)
				}
			}

			RadialGradient(
				colors: [.clear, .black.opacity(0.06)],
				center: .center,
				startRadius: 180,
				endRadius: 650
			)
		}
		.ignoresSafeArea()
	}
}

#Preview {
	PaperBackground()
}
