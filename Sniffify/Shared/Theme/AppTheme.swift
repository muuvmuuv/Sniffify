//
//  AppTheme.swift
//  Sniffify
//
//  App-wide theme definitions including colors, typography, and spacing.
//

import SwiftUI

// MARK: - App Spacing

enum AppSpacing {
	static let xxs: CGFloat = 2
	static let xs: CGFloat = 4
	static let sm: CGFloat = 8
	static let md: CGFloat = 12
	static let lg: CGFloat = 16
	static let xl: CGFloat = 20
	static let xxl: CGFloat = 24
	static let xxxl: CGFloat = 32

	// MARK: Component Specific

	static let cardPadding: CGFloat = 16
	static let listRowPadding: CGFloat = 12
	static let sectionSpacing: CGFloat = 24
	static let screenPadding: CGFloat = 16
}

// MARK: - App Corner Radius

enum AppCornerRadius {
	static let small: CGFloat = 8
	static let medium: CGFloat = 12
	static let large: CGFloat = 16
	static let extraLarge: CGFloat = 20
	static let pill: CGFloat = 9999
}

// MARK: - App Animations

enum AppAnimations {
	static let quick = Animation.easeInOut(duration: 0.15)
	static let standard = Animation.easeInOut(duration: 0.25)
	static let smooth = Animation.easeInOut(duration: 0.35)

	static let spring = Animation.spring(response: 0.35, dampingFraction: 0.7)
	static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
	static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.8)
}

// MARK: - Paper Theme

/// Sniffify's hand-drawn look: warm paper, ink outlines, marker accents.
/// Mirrors the crumpled-paper mockups from the sketch; every screen paints
/// with these.
enum PaperColors {
	static let paper = Color(red: 0.94, green: 0.93, blue: 0.89)
	static let ink = Color(red: 0.13, green: 0.12, blue: 0.11)
	static let pencil = Color(red: 0.45, green: 0.44, blue: 0.42)
	static let marker = Color(red: 0.55, green: 0.10, blue: 0.75)
	static let noseSkin = Color(red: 0.85, green: 0.55, blue: 0.25)
	static let crown = Color(red: 0.95, green: 0.78, blue: 0.10)
	static let cone = Color(red: 0.90, green: 0.45, blue: 0.10)
	static let check = Color(red: 0.30, green: 0.75, blue: 0.20)
	static let cross = Color(red: 0.80, green: 0.15, blue: 0.10)
}

/// Handwriting fonts for the doodle look — all iOS built-ins, nothing bundled.
enum DoodleFont {
	static func wordmark(_ size: CGFloat) -> Font { .custom("Chalkduster", size: size) }
	static func heading(_ size: CGFloat) -> Font { .custom("ChalkboardSE-Bold", size: size) }
	static func hand(_ size: CGFloat) -> Font { .custom("BradleyHandITCTT-Bold", size: size) }
}
