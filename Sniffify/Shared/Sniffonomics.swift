//
//  Sniffonomics.swift
//  Sniffify
//
//  The satirical domain "science": personal line formula, the fake friends
//  roster, and the Wrapped distance ladder. All values are jokes — tune
//  freely.
//

import Foundation

enum Sniffonomics {
	/// One Nasenlänge — the eternal gap between you and Maximilian.
	static let nasenlaengeCm: Double = 7
	/// Maximilian's Notendurchschnitt is always this much better than yours —
	/// even when that means a 0,9.
	static let maximilianGradeLead: Double = 0.1
	/// Maximilian's Notendurchschnitt while you have none yet.
	static let maximilianIdleGrade: Double = 4.0

	/// Screen points per physical centimeter, so the line renders true to
	/// size. Derived from typical iPhone panel density (~460 ppi @3x,
	/// ~326 ppi @2x).
	/// ponytail: real PPI varies a few percent per model; a per-model table
	/// (or a one-time credit-card calibration screen) is the upgrade path.
	static func pointsPerCm(displayScale: CGFloat) -> CGFloat {
		displayScale >= 3 ? 60.4 : 64.2
	}

	/// Official Sniffify conversion: 1 cm gezogene Line = 1 km Fußweg.
	/// Without this inflation nobody ever leaves the village.
	static let kmPerCm: Double = 1

	/// Comedic dose formula: taller + heavier ⇒ longer line. Tuned so real
	/// bodies land in a sniffable 5–12 cm that fits on screen at true scale
	/// (1,82 m / 90 kg ⇒ 10,9 cm).
	static func lineLengthCm(heightCm: Double, weightKg: Double) -> Double {
		min(max((heightCm + weightKg) / 25, 5), 12)
	}

	/// Comedic dose formula: heavier ⇒ fatter line.
	static func lineWidthMm(weightKg: Double) -> Double {
		min(3 + weightKg / 40, 8)
	}

	/// Official pulling rate: this many seconds of heard pull clear 1 cm of
	/// line. A full, clean pull is heard for ≈ 0,75 s and clears a 10 cm line
	/// in one go; a weaker one needs a second attempt — which costs a grade.
	/// ponytail: tuned on three captures of direct pulls — `just replay`
	/// prints the cm a capture's pulls would clear.
	static let pullSecondsPerCm: Double = 0.07

	// MARK: - Bewertung

	/// Finishing within this after zero counts as „PERFEKT".
	static let perfectSeconds: Double = 1.5

	/// Amtliche Schulnote 1…6 for a cleared line: one pull within
	/// `perfectSeconds` is a 1; every extra attempt costs a grade, and so
	/// does dawdling after zero.
	static func grade(pulls: Int, seconds: Double) -> Int {
		let dawdling =
			switch seconds {
			case ...perfectSeconds: 0
			case ...4: 1
			case ...8: 2
			default: 3
			}
		return min(6, max(1, pulls) + dawdling)
	}

	/// The Zeugnis line for a grade, with the official German grade word.
	static func gradeVerdict(_ grade: Int) -> String {
		switch grade {
		case 1: "Note 1 — sehr gut\nEin Zug, alles weg. PERFEKT!"
		case 2: "Note 2 — gut\nMaximilian hätte es schneller gezogen."
		case 3: "Note 3 — befriedigend\nSolide Nachzieharbeit."
		case 4: "Note 4 — ausreichend\nDie Nase muss nachsitzen."
		case 5: "Note 5 — mangelhaft\nMehr daneben als drin."
		default: "Note 6 — ungenügend\nSetzen."
		}
	}

	// MARK: - Bestenliste

	struct Friend: Identifiable {
		let name: String
		let totalCm: Double
		/// Notendurchschnitt — the Bestenliste ranks by it.
		let averageGrade: Double
		var id: String { name }
	}

	/// Static rivals; beatable. Maximilian is NOT here — he is always exactly
	/// one Nasenlänge and `maximilianGradeLead` ahead of the user, forever
	/// ("Maximilian ist dir eine Nasenlänge voraus.").
	static let friends: [Friend] = [
		Friend(name: "Sepp", totalCm: 480, averageGrade: 1.4),
		Friend(name: "Vroni", totalCm: 260, averageGrade: 2.1),
		Friend(name: "Xaver", totalCm: 95, averageGrade: 4.3),
	]

	// MARK: - Wrapped

	/// Walking-distance punchline for the year total (already inflated via
	/// kmPerCm). Ladder ends in Peru like the sketch.
	static func destination(forKm km: Double) -> String {
		switch km {
		case ..<1: return "bis zum Kühlschrank"
		case ..<5: return "einmal ums Dorf"
		case ..<40: return "ins Nachbardorf"
		case ..<300: return "nach München"
		case ..<900: return "über die Alpen nach Südtirol"
		case ..<2_500: return "nach Paris"
		case ..<6_000: return "nach Lissabon"
		case ..<9_500: return "nach New York"
		default: return "bis nach Peru"
		}
	}
}
