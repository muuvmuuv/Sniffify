//
//  MainTabView.swift
//  Sniffify
//
//  Main navigation with tabs.
//

import SwiftUI

struct MainTabView: View {
	@State private var selectedTab = 0

	var body: some View {
		TabView(selection: $selectedTab) {
			Tab("Ziehen", systemImage: "nose", value: 0) {
				SniffView()
			}

			Tab("Bestenliste", systemImage: "trophy", value: 1) {
				LeaderboardView()
			}

			Tab("Wrapped", systemImage: "chart.pie", value: 2) {
				WrappedView()
			}

			Tab("Einstellungen", systemImage: "gearshape", value: 3) {
				SettingsView()
			}
		}
	}
}

#Preview {
	MainTabView()
}
