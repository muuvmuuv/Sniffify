# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sniffify is a **private satirical iOS gag app** for an adult friend who uses
snuff tobacco (legal Schnupftabak). It recreates the fictional app from a
German stand-up sketch (<https://www.instagram.com/p/DbBXNMXi5J2/> — video,
transcript, and mockup frames in `assets/`). It is never store-distributed;
all user-facing copy is German satire. The content is intentional — keep it
tobacco-themed and adults-only, and don't sand the jokes off.

**Target:** iPhone/iPad, iOS 26+, Swift, SwiftUI, SwiftData. **No external
dependencies** — pure SwiftUI (Canvas, KeyframeAnimator, TimelineView) plus
AVFoundation and small UIKit shims where SwiftUI has no API
(`UITouch.majorRadius` in `Shared/Components/TouchLineOverlay.swift`).

## Domain Cheat Sheet

- `Shared/Sniffonomics.swift` — the satire "science": line formula, fake
  friends, Nasenlänge (7 cm, Maximilian's eternal lead), 1 cm = 1 km Wrapped
  conversion, destination ladder, points-per-cm for true physical line size.
- `Features/Sniff/` — the core gag: `SniffSessionViewModel` state machine
  (briefing → countdown → armed ±1.5 s window → success/fail; fusion = mic
  spike AND ≥60 % nose-track coverage, degrading to touch-only when the mic
  is denied or dead), locked full-screen `SniffSessionView` (idle timer off,
  deferred system gestures, hold-the-lock escape), `SniffResultOverlay`
  (mascot shovel flight keyed off ONE keyframe value).
- `Core/Audio/SniffAudioService.swift` — AVAudioEngine tap, noise-floor EMA
  + spike gates, ZCR for the Röhrchen heuristic, optional `.caf` debug
  capture to `Documents/SniffCaptures/`.
- Calibration constants are marked with `ponytail:` comments — they are meant
  to be tuned from debug captures, not hardcoded away.

## Build Commands

```bash
just              # List all commands
just format       # Format all Swift files (swift-format, config in .swift-format)
just build        # Build for simulator (debug)
just check        # Format and build
just open         # Open project in Xcode
just lsp          # Build SPM for VS Code LSP
```

Always run `just format` after changes. The project uses a
`PBXFileSystemSynchronizedRootGroup`: files added on disk under `Sniffify/`
auto-join the target — no pbxproj edits needed. Info.plist is generated;
usage keys live as `INFOPLIST_KEY_*` build settings in `project.pbxproj`
(both configs).

## Signing

`DEVELOPMENT_TEAM` never gets committed: a git clean filter (`.gitattributes`)
strips it from `project.pbxproj` on the way into commits/diffs, while Xcode
keeps it in the working copy for local signing. The filter driver is per-clone —
run `just setup` once after a fresh clone.

## Conventions

- Layers: App (entry) → Features (UI) → Core (domain) → Shared (components/theme).
  See [ARCHITECTURE.md](ARCHITECTURE.md).
- Paper look everywhere: `PaperBackground` + `PaperColors`/`DoodleFont`
  (in `Shared/Theme/AppTheme.swift`), rough shapes from
  `Shared/Components/SketchShapes.swift`. The template's dark `AppColors`
  palette is intentionally unused.
- Persistence: ONE SwiftData model (`SniffSession`), queried directly in
  views; the profile is `@AppStorage` — deliberately no stores.
- Strings: German literals only, no `.xcstrings` entries — private gag app,
  deliberate deviation from the template's de+en rule.
- **NEVER commit without user approval.**

## Versioning

Semantic Versioning via `MARKETING_VERSION` in the Xcode project.
