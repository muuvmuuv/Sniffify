//
//  View+Extensions.swift
//  Sniffify
//
//  View modifiers and extensions.
//

import SwiftUI

// MARK: - Safe Area Insets

extension UIApplication {
	var safeAreaInsets: EdgeInsets {
		let insets =
			connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first { $0.isKeyWindow }?
			.safeAreaInsets ?? .zero
		return EdgeInsets(
			top: insets.top,
			leading: insets.left,
			bottom: insets.bottom,
			trailing: insets.right
		)
	}
}

// MARK: - Inline Title Toolbar

struct InlineTitleToolbar: ViewModifier {
	let title: LocalizedStringKey

	func body(content: Content) -> some View {
		content
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text(title)
						.font(.title.bold())
				}
			}
	}
}

extension View {
	func inlineTitle(_ title: LocalizedStringKey) -> some View {
		modifier(InlineTitleToolbar(title: title))
	}
}

// MARK: - Glass Effect

extension View {
	/// Applies the standard interactive glass effect.
	func adaptiveGlass() -> some View {
		glassEffect(.regular.interactive())
	}
}
