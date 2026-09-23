//
//  WrappedView.swift
//  Sniffify
//
//  The year recap from the sketch: totals, Notendurchschnitt, Nasenkilometer,
//  the walking destination punchline, and the Alleine/Mit-Freunden doodle
//  pie — shareable as an image.
//

import SwiftData
import SwiftUI

struct WrappedView: View {
	@Query private var sessions: [SniffSession]

	private var year: Int {
		Calendar.current.component(.year, from: .now)
	}

	/// Every attempt this year, failed ones included — they count in the
	/// Notendurchschnitt.
	private var yearSessions: [SniffSession] {
		sessions.filter { Calendar.current.component(.year, from: $0.date) == year }
	}

	private var yearLines: [SniffSession] {
		yearSessions.filter(\.success)
	}

	private var totalCm: Double {
		yearLines.reduce(0) { $0 + $1.lineLengthCm }
	}

	private var km: Double {
		totalCm * Sniffonomics.kmPerCm
	}

	private var aloneFraction: Double {
		guard !yearLines.isEmpty else { return 1 }
		let alone = yearLines.filter { !$0.withFriends }.count
		return Double(alone) / Double(yearLines.count)
	}

	var body: some View {
		ZStack {
			PaperBackground()

			ScrollView {
				VStack(spacing: AppSpacing.sectionSpacing) {
					card
						.padding(.top, AppSpacing.xxl)

					ShareLink(
						item: cardImage,
						preview: SharePreview("Sniffify Wrapped \(String(year))", image: cardImage)
					) {
						Text("Teilen 📤")
					}
					.buttonStyle(DoodleButtonStyle(color: PaperColors.marker))
					.padding(.bottom, AppSpacing.xxxl)
				}
				.padding(AppSpacing.screenPadding)
			}
		}
	}

	// MARK: - Card

	private var card: some View {
		VStack(spacing: AppSpacing.xl) {
			Text("SNIFFIFY")
				.font(DoodleFont.wordmark(38))
				.foregroundStyle(PaperColors.ink)
			Text("W r a p p e d  \(String(year))")
				.font(DoodleFont.heading(22))
				.foregroundStyle(PaperColors.marker)

			RoughLine(seed: 21)
				.stroke(PaperColors.pencil, lineWidth: 1.5)
				.frame(height: 8)
				.padding(.horizontal, AppSpacing.xxxl)

			VStack(spacing: AppSpacing.sm) {
				Text("\(yearLines.count) Lines gezogen")
					.font(DoodleFont.hand(18))
				Text("\((totalCm / 100).formatted(.number.precision(.fractionLength(1)))) m Gesamtlänge")
					.font(DoodleFont.hand(18))
				if let average = yearSessions.averageGrade {
					Text("Notendurchschnitt: \(average.formatted(.number.precision(.fractionLength(1))))")
						.font(DoodleFont.heading(18))
						.foregroundStyle(PaperColors.marker)
				}
				if let best = yearLines.filter({ $0.seconds > 0 }).map(\.seconds).min() {
					Text(
						"Schnellste Nase: \(best.formatted(.number.precision(.fractionLength(1)))) s"
					)
					.font(DoodleFont.hand(18))
				}
			}
			.foregroundStyle(PaperColors.ink)

			VStack(spacing: AppSpacing.xs) {
				Text("Zu Fuß wärst du damit")
					.font(DoodleFont.hand(16))
					.foregroundStyle(PaperColors.pencil)
				Text(Sniffonomics.destination(forKm: km) + " gekommen!")
					.font(DoodleFont.heading(21))
					.foregroundStyle(PaperColors.marker)
					.multilineTextAlignment(.center)
				Text("(\(Int(km)) Nasenkilometer, amtlich)")
					.font(DoodleFont.hand(13))
					.foregroundStyle(PaperColors.pencil)
			}

			DoodlePie(aloneFraction: aloneFraction)
				.frame(width: 150, height: 150)
				.padding(AppSpacing.xl)

			HStack(spacing: AppSpacing.xl) {
				legend(color: PaperColors.paper, label: "Alleine")
				legend(color: PaperColors.marker.opacity(0.18), label: "Mit Freunden")
			}
		}
		.padding(AppSpacing.xxl)
		.background {
			RoughRect(seed: 33, jitter: 3)
				.stroke(PaperColors.ink, lineWidth: 2.5)
		}
	}

	private func legend(color: Color, label: String) -> some View {
		HStack(spacing: AppSpacing.xs) {
			RoughRect(seed: UInt64(label.count))
				.stroke(PaperColors.ink, lineWidth: 1.5)
				.background(color)
				.frame(width: 16, height: 16)
			Text(label)
				.font(DoodleFont.hand(14))
				.foregroundStyle(PaperColors.ink)
		}
	}

	private var cardImage: Image {
		let renderer = ImageRenderer(
			content:
				card
				.frame(width: 380)
				.padding(AppSpacing.xl)
				.background(PaperColors.paper)
		)
		renderer.scale = 3
		if let image = renderer.uiImage {
			return Image(uiImage: image)
		}
		return Image(systemName: "photo")
	}
}

#Preview {
	WrappedView()
		.modelContainer(for: SniffSession.self, inMemory: true)
}
