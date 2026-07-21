# Architecture

This document describes the architecture and patterns used in Sniffify.

## Layered Architecture

```
┌─────────────────────────────────────────┐
│                  App                    │  Entry point, app lifecycle
├─────────────────────────────────────────┤
│               Features                  │  UI Views + ViewModels
├─────────────────────────────────────────┤
│                 Core                    │  Domain logic, services, persistence
├─────────────────────────────────────────┤
│                Shared                   │  Components, extensions, theme
└─────────────────────────────────────────┘
```

## Folder Structure

```
Sniffify/
├── App/                        # Entry point
│   ├── SniffifyApp.swift       # ModelContainer setup, onboarding gate, light/paper root
│   └── MainTabView.swift       # Ziehen / Bestenliste / Wrapped / Einstellungen
│
├── Core/
│   ├── Audio/
│   │   └── SniffAudioService.swift   # AVAudioEngine tap: spike + ZCR detection, debug capture
│   ├── Persistence/
│   │   ├── AppSchema.swift           # model registry
│   │   └── Models/SniffSession.swift # the ONE SwiftData model (one row per attempt)
│   └── Logger.swift
│
├── Features/
│   ├── Onboarding/             # 18+ satire splash + height/weight profile
│   ├── Sniff/                  # the core gag: view, locked session, VM state machine, result overlay
│   ├── Leaderboard/            # podium, Maximilian one Nasenlänge ahead
│   ├── Wrapped/                # year recap + doodle pie + share-as-image
│   └── Settings/               # profile, reset, debug audio captures
│
├── Shared/
│   ├── Components/             # hand-drawn kit: SketchShapes (seeded wobble), PaperBackground,
│   │                           # NoseDoodle, NoseWallpaper, SegmentedLineView, DoodlePie,
│   │                           # TouchLineOverlay (UIKit majorRadius), Feedback (haptics)
│   ├── Extensions/
│   ├── Theme/                  # AppTheme + PaperColors/DoodleFont (paper look)
│   └── Sniffonomics.swift      # satire domain: formulas, friends, destinations, points-per-cm
│
└── Assets.xcassets/            # crowned-nose AppIcon, cream launch bg, marker accent

assets/ (repo root)             # README preview media (screenshots, demo video, icon),
                                # all downscaled + metadata-stripped
```

## Threading Model

### MainActor Types
Use `@MainActor` for:
- ViewModels
- UI-related singletons (stores that update UI)
- Any type that modifies SwiftUI state

```swift
@MainActor
final class ItemStore {
    static let shared = ItemStore()
    // ...
}
```

### Actor Types
Use `actor` for:
- Network services
- Background processing
- Anything that doesn't directly update UI

```swift
actor NetworkService {
    func fetchData() async throws -> Data {
        // ...
    }
}
```

## Data Flow

```
┌─────────────┐     ┌──────────────────────┐     ┌───────────────────┐
│    View     │────▶│ SniffSessionViewModel │────▶│ SniffAudioService │
└─────────────┘     └──────────────────────┘     └───────────────────┘
       ▲                        │
       │                        ▼
       └──── @Query ────  SwiftData (SniffSession)
```

1. **Views** read `SniffSession` rows directly via `@Query` and insert via
   `modelContext` — there are ~2 write sites, so no store layer exists
   (deliberate simplification).
2. The only ViewModel is `SniffSessionViewModel` (@MainActor @Observable):
   it owns the countdown state machine, consumes the audio service's
   `AsyncStream`, and fuses mic + touch into the verdict.
3. The user profile is `@AppStorage` (height/weight/hasOnboarded), not a
   model — single-instance data with no query need.

## SwiftData Integration

### Schema Definition
All models are registered in `AppSchema.swift`:

```swift
enum AppSchema {
    static let models: [any PersistentModel.Type] = [
        SniffSession.self
    ]
}
```

### Model Guidelines
- Keep models simple data containers
- Avoid business logic in models
- Use ID-based references for relationships (CloudKit compatible)

## Adding a New Feature

1. Create folder under `Features/`
2. Add View and ViewModel
3. Register in `MainTabView` if it's a tab
4. Add any required models to `AppSchema`

Example structure:
```
Features/
└── NewFeature/
    ├── NewFeatureView.swift
    └── NewFeatureViewModel.swift
```

## Navigation

Uses SwiftUI's native navigation:
- `NavigationStack` for hierarchical navigation
- `TabView` with `Tab` for tab-based navigation
- Sheet/fullScreenCover for modals
