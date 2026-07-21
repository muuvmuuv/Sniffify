//
//  AppTheme.swift
//  Sniffify
//
//  App-wide theme definitions including colors, typography, and spacing.
//

import SwiftUI

// MARK: - App Colors

enum AppColors {
	// MARK: Brand Colors

	/// Dark background color - customize for your brand
	static let dark = Color(red: 0.067, green: 0.067, blue: 0.067)
	/// Primary accent color - customize for your brand
	static let primary = Color.accentColor
	/// Light foreground color
	static let light = Color(red: 0.96, green: 0.96, blue: 0.96)

	// MARK: Semantic Colors

	static let accent = Color.accentColor
	static let accentLight = Color.accentColor.opacity(0.2)

	// MARK: Text Colors

	static let textPrimary = Color.primary
	static let textSecondary = Color.secondary
	static let textTertiary = Color(uiColor: .tertiaryLabel)

	// MARK: Background Colors

	static let backgroundPrimary = dark
	static let backgroundSecondary = dark.opacity(0.9)

	// MARK: Status Colors

	static let success = Color.green
	static let warning = Color.orange
	static let error = Color.red
}

// MARK: - App Typography

enum AppTypography {
	// MARK: Titles

	static let largeTitle = Font.largeTitle.weight(.bold)
	static let title = Font.title.weight(.bold)
	static let title2 = Font.title2.weight(.semibold)
	static let title3 = Font.title3.weight(.semibold)

	// MARK: Body

	static let headline = Font.headline
	static let body = Font.body
	static let callout = Font.callout
	static let subheadline = Font.subheadline
	static let footnote = Font.footnote
	static let caption = Font.caption
	static let caption2 = Font.caption2

	// MARK: Special

	static let monospacedDigits = Font.body.monospacedDigit()
	static let monospacedCaption = Font.caption.monospacedDigit()
}

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

// MARK: - View Modifiers

extension View {
	/// Applies standard card shadow.
	func cardShadow() -> some View {
		shadow(color: .black.opacity(0.15), radius: 8, y: 4)
	}

	/// Applies glass border overlay.
	func glassBorder(cornerRadius: CGFloat = AppCornerRadius.large) -> some View {
		overlay {
			RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
				.strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
		}
	}
}

// MARK: - Paper Theme

/// Sniffify's hand-drawn look: warm paper, ink outlines, marker accents.
/// Mirrors the crumpled-paper mockups from the sketch; used instead of the
/// dark AppColors palette on every screen.
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
