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

	// MARK: - Bestenliste

	struct Friend: Identifiable {
		let name: String
		let totalCm: Double
		var id: String { name }
	}

	/// Static rivals; beatable. Maximilian is NOT here — he is always exactly
	/// one Nasenlänge ahead of the user, forever ("Maximilian ist dir eine
	/// Nasenlänge voraus.").
	static let friends: [Friend] = [
		Friend(name: "Sepp", totalCm: 480),
		Friend(name: "Vroni", totalCm: 260),
		Friend(name: "Xaver", totalCm: 95),
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
