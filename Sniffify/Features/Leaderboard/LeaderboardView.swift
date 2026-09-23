//
//  LeaderboardView.swift
//  Sniffify
//
//  "Die schnellste Nase": podium + list of fake friends and the user,
//  ranked by Notendurchschnitt (failed lines count as a 6), with the
//  accumulated line length beside it. Maximilian is always exactly one
//  Nasenlänge and a tenth of a grade ahead — that's the joke, he is not
//  meant to be beatable.
//

import SwiftData
import SwiftUI

struct LeaderboardView: View {
	@Query private var sessions: [SniffSession]

	private struct Entry: Identifiable {
		let name: String
		let totalCm: Double
		/// Notendurchschnitt; nil until the first session.
		let averageGrade: Double?
		let isUser: Bool
		var id: String { name }
	}

	private var entries: [Entry] {
		let myTotal = sessions.filter(\.success).reduce(0) { $0 + $1.lineLengthCm }
		let myGrade = sessions.averageGrade
		var all = Sniffonomics.friends.map {
			Entry(name: $0.name, totalCm: $0.totalCm, averageGrade: $0.averageGrade, isUser: false)
		}
		all.append(
			Entry(
				name: "Maximilian", totalCm: myTotal + Sniffonomics.nasenlaengeCm,
				averageGrade: myGrade.map { $0 - Sniffonomics.maximilianGradeLead } ?? Sniffonomics.maximilianIdleGrade,
				isUser: false))
		all.append(Entry(name: "Du", totalCm: myTotal, averageGrade: myGrade, isUser: true))
		// no grade yet = unranked, below everyone
		return all.sorted { ($0.averageGrade ?? 7) < ($1.averageGrade ?? 7) }
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
						Text("nach Notendurchschnitt")
							.font(DoodleFont.hand(12))
							.foregroundStyle(PaperColors.pencil)
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
			VStack(alignment: .trailing, spacing: 0) {
				Text(
					"Ø \(entry.averageGrade.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? "–")"
				)
				.font(DoodleFont.heading(16))
				Text("\((entry.totalCm / 100).formatted(.number.precision(.fractionLength(2)))) m")
					.font(DoodleFont.hand(12))
					.opacity(0.7)
			}
		}
		.foregroundStyle(entry.isUser ? PaperColors.marker : PaperColors.ink)
	}
}

#Preview {
	LeaderboardView()
		.modelContainer(for: SniffSession.self, inMemory: true)
}
