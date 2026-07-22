//
//  SettingsView.swift
//  Sniffify
//
//  Profile editing, data reset, and the satire small print.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
	@AppStorage("heightCm") private var heightCm = 180.0
	@AppStorage("weightKg") private var weightKg = 80.0
	@AppStorage("hasOnboarded") private var hasOnboarded = false
	@AppStorage("debugAudioCapture") private var debugAudioCapture = false
	@AppStorage("lineHelper") private var lineHelper = ""
	@Environment(\.modelContext) private var modelContext
	@State private var confirmReset = false
	@State private var captures: [URL] = []

	var body: some View {
		NavigationStack {
			ZStack {
				PaperBackground()

				List {
					Section("Profil") {
						VStack(alignment: .leading, spacing: AppSpacing.xs) {
							Text("Größe: \(Int(heightCm)) cm")
								.font(DoodleFont.hand(16))
							Slider(value: $heightCm, in: 140...210, step: 1)
						}
						VStack(alignment: .leading, spacing: AppSpacing.xs) {
							Text("Gewicht: \(Int(weightKg)) kg")
								.font(DoodleFont.hand(16))
							Slider(value: $weightKg, in: 40...200, step: 1)
						}
						LabeledContent("Offizielle Line") {
							Text(
								"\(Sniffonomics.lineLengthCm(heightCm: heightCm, weightKg: weightKg).formatted(.number.precision(.fractionLength(1)))) cm"
							)
						}
						.font(DoodleFont.hand(16))
					}

					Section("Helfer") {
						Picker("Figur", selection: $lineHelper) {
							Text("Automatisch").tag("")
							Text("Nur Schaufel-Helfer").tag("shoveler")
							Text("Nur Sandmännchen").tag("sandmann")
						}
						.font(DoodleFont.hand(16))
						Text(
							"Ohne Auswahl entscheidet die Uhrzeit: tagsüber schaufelt der gelbe Helfer, ab 19 Uhr übernimmt das Sandmännchen."
						)
						.font(DoodleFont.hand(12))
						.foregroundStyle(PaperColors.pencil)
					}

					Section("Daten") {
						Button("Alles zurücksetzen", role: .destructive) {
							confirmReset = true
						}
						.font(DoodleFont.hand(16))
					}

					Section("Debug") {
						Toggle(isOn: $debugAudioCapture) {
							Text("Sniff-Aufnahmen speichern")
								.font(DoodleFont.hand(16))
						}
						Text(
							"Zeichnet das Mikrofon während des Zieh-Fensters als .caf auf — zum Kalibrieren der Erkennung. Auch per Dateien-App erreichbar."
						)
						.font(DoodleFont.hand(12))
						.foregroundStyle(PaperColors.pencil)
						ForEach(captures, id: \.self) { url in
							ShareLink(item: url) {
								Label(url.lastPathComponent, systemImage: "waveform")
									.font(DoodleFont.hand(14))
							}
						}
						if !captures.isEmpty {
							Button("Aufnahmen löschen", role: .destructive) {
								captures.forEach { try? FileManager.default.removeItem(at: $0) }
								reloadCaptures()
							}
							.font(DoodleFont.hand(14))
						}
					}

					Section("Über") {
						LabeledContent("Version", value: appVersion)
							.font(DoodleFont.hand(16))
						Text("Reine Satire unter Erwachsenen. Ab 18.\nFunktioniert ausschließlich mit Schnupftabak.")
							.font(DoodleFont.hand(13))
							.foregroundStyle(PaperColors.pencil)
					}
				}
				.scrollContentBackground(.hidden)
				.tint(PaperColors.marker)
			}
			.navigationTitle("Einstellungen")
			.onAppear { reloadCaptures() }
			.confirmationDialog("Wirklich alles vergessen?", isPresented: $confirmReset, titleVisibility: .visible) {
				Button("Ja, Nase auf null", role: .destructive) { resetAll() }
				Button("Abbrechen", role: .cancel) {}
			}
		}
	}

	private func resetAll() {
		try? modelContext.delete(model: SniffSession.self)
		hasOnboarded = false
	}

	private func reloadCaptures() {
		captures =
			((try? FileManager.default.contentsOfDirectory(
				at: SniffSessionViewModel.capturesDirectory, includingPropertiesForKeys: nil)) ?? [])
			.filter { $0.pathExtension == "caf" }
			.sorted { $0.lastPathComponent > $1.lastPathComponent }
	}

	private var appVersion: String {
		let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
		let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
		return "\(version) (\(build))"
	}
}

#Preview {
	SettingsView()
		.modelContainer(for: SniffSession.self, inMemory: true)
}
