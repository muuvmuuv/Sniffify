//
//  SniffifyApp.swift
//  Sniffify
//
//  Main app entry point with SwiftData setup.
//

import OSLog
import SwiftData
import SwiftUI
import UIKit

/// Delegate exists solely to make the orientation mask dynamic — the sniff
/// session locks rotation to its starting orientation via OrientationLock
/// so a nose hovering over the gyro can't flip the layout mid-line.
final class AppDelegate: NSObject, UIApplicationDelegate {
	static var orientationLock: UIInterfaceOrientationMask = .all

	func application(
		_ application: UIApplication,
		supportedInterfaceOrientationsFor window: UIWindow?
	) -> UIInterfaceOrientationMask {
		Self.orientationLock
	}
}

enum OrientationLock {
	private static var scene: UIWindowScene? {
		UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
	}

	/// Freezes rotation in the current orientation.
	static func lockToCurrent() {
		guard let scene else { return }
		AppDelegate.orientationLock = scene.interfaceOrientation.isLandscape ? .landscape : .portrait
		scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
	}

	static func unlock() {
		AppDelegate.orientationLock = .all
		scene?.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
	}
}

@main
struct SniffifyApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

	/// The shared model container, or an error if initialization failed.
	private let modelContainerResult: Result<ModelContainer, Error>

	init() {
		modelContainerResult = Self.createModelContainer()
	}

	/// Creates the model container.
	private static func createModelContainer() -> Result<ModelContainer, Error> {
		do {
			let schema = Schema(AppSchema.models)
			let configuration = ModelConfiguration(schema: schema)
			let container = try ModelContainer(for: schema, configurations: [configuration])
			return .success(container)
		} catch {
			Log.persistence.error("Failed to create ModelContainer: \(error.localizedDescription)")
			return .failure(error)
		}
	}

	var body: some Scene {
		WindowGroup {
			switch modelContainerResult {
			case .success(let container):
				ContentView()
					.modelContainer(container)
			case .failure(let error):
				ErrorView(error: error)
			}
		}
	}
}

// MARK: - Content View

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("hasOnboarded") private var hasOnboarded = false
	@State private var isInitialized = false

	var body: some View {
		ZStack {
			PaperColors.paper
				.ignoresSafeArea()

			if isInitialized {
				MainTabView()
					.transition(.opacity)
			} else {
				ProgressView()
					.tint(PaperColors.ink)
					.transition(.opacity)
			}
		}
		.animation(.easeInOut(duration: 0.4), value: isInitialized)
		.task {
			isInitialized = true
		}
		.preferredColorScheme(.light)
		.fullScreenCover(
			isPresented: Binding(
				get: { !hasOnboarded },
				set: { hasOnboarded = !$0 }
			)
		) {
			OnboardingView()
		}
	}
}

// MARK: - Error View

struct ErrorView: View {
	let error: Error

	var body: some View {
		VStack(spacing: 16) {
			Image(systemName: "exclamationmark.triangle")
				.font(.largeTitle)
				.foregroundStyle(.red)

			Text("Initialization Error")
				.font(.headline)

			Text(error.localizedDescription)
				.font(.caption)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
		}
	}
}

#Preview {
	ContentView()
}
