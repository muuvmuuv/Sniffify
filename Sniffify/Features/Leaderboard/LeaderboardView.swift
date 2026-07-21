//
//  LeaderboardView.swift
//  Sniffify
//
//  "Die schnellste Nase": podium + ranked list of fake friends against the
//  user's accumulated line length. Maximilian is always exactly one
//  Nasenlänge ahead — that's the joke, he is not meant to be beatable.
//

import SwiftData
import SwiftUI

struct LeaderboardView: View {
	@Query(filter: #Predicate<SniffSession> { $0.success == true })
	private var sessions: [SniffSession]

	private struct Entry: Identifiable {
		let name: String
		let totalCm: Double
		let isUser: Bool
		var id: String { name }
	}

	private var entries: [Entry] {
		let myTotal = sessions.reduce(0) { $0 + $1.lineLengthCm }
		var all = Sniffonomics.friends.map { Entry(name: $0.name, totalCm: $0.totalCm, isUser: false) }
		all.append(Entry(name: "Maximilian", totalCm: myTotal + Sniffonomics.nasenlaengeCm, isUser: false))
		all.append(Entry(name: "Du", totalCm: myTotal, isUser: true))
		return all.sorted { $0.totalCm > $1.totalCm }
	}

	var body: some View {
		ZStack {
			PaperBackground()

			ScrollView {
				VStack(spacing: AppSpacing.sectionSpacing) {
					VStack(spacing: AppSpacing.xs) {
						Text("BESTENLISTE")
							.font(DoodleFont.wordmark(34))
							.foregroundStyle(PaperColors.ink)
						Text("Die schnellste Nase")
							.font(DoodleFont.hand(16))
							.foregroundStyle(PaperColors.marker)
					}
					.padding(.top, AppSpacing.xxl)

					podium

					Text("Maximilian ist dir eine Nasenlänge voraus.")
						.font(DoodleFont.heading(16))
						.foregroundStyle(PaperColors.marker)
						.rotationEffect(.degrees(-2))

					VStack(spacing: AppSpacing.md) {
						ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
							row(rank: index + 1, entry: entry)
						}
					}
					.padding(.horizontal, AppSpacing.lg)
				}
				.padding(AppSpacing.screenPadding)
			}
		}
	}

	// MARK: - Podium

	private var podium: some View {
		let top = entries
		return HStack(alignment: .bottom, spacing: AppSpacing.md) {
			if top.count > 1 { podiumColumn(rank: 2, entry: top[1], height: 92) }
			if !top.isEmpty { podiumColumn(rank: 1, entry: top[0], height: 130) }
			if top.count > 2 { podiumColumn(rank: 3, entry: top[2], height: 70) }
		}
	}

	private func podiumColumn(rank: Int, entry: Entry, height: CGFloat) -> some View {
		VStack(spacing: AppSpacing.sm) {
			if rank == 1 {
				Text("👑").font(.system(size: 26))
			}
			Text(entry.name)
				.font(DoodleFont.hand(15))
				.foregroundStyle(entry.isUser ? PaperColors.marker : PaperColors.ink)
			ZStack {
				RoughRect(seed: UInt64(rank))
					.stroke(PaperColors.ink, lineWidth: 2.5)
					.background(PaperColors.ink.opacity(0.05))
				Text("\(rank)")
					.font(DoodleFont.wordmark(38))
					.foregroundStyle(PaperColors.ink)
			}
			.frame(width: 86, height: height)
		}
	}

	// MARK: - List

	private func row(rank: Int, entry: Entry) -> some View {
		HStack {
			Text("\(rank).")
				.font(DoodleFont.heading(17))
			Text(entry.name)
				.font(DoodleFont.hand(17))
			Spacer()
			Text("\((entry.totalCm / 100).formatted(.number.precision(.fractionLength(2)))) m")
				.font(DoodleFont.heading(16))
		}
		.foregroundStyle(entry.isUser ? PaperColors.marker : PaperColors.ink)
	}
}

#Preview {
	LeaderboardView()
		.modelContainer(for: SniffSession.self, inMemory: true)
}
