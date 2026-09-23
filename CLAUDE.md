# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sniffify is a **satirical iOS gag app** for an adult friend who uses
snuff tobacco (legal Schnupftabak). It recreates the fictional app from a
German stand-up sketch (<https://www.instagram.com/p/DbBXNMXi5J2/>). The
full sketch video and transcript are deliberately NOT in this public repo —
never re-add them; only a handful of metadata-stripped mockup frames live in
`assets/ref-*.jpg` as design reference. The app is never store-distributed;
all user-facing copy is German satire. The content is intentional — keep it
tobacco-themed and adults-only, and don't sand the jokes off.

**Target:** iPhone/iPad, iOS 26+, Swift, SwiftUI, SwiftData. **No external
dependencies** — pure SwiftUI (Canvas, KeyframeAnimator, TimelineView) plus
AVFoundation and small UIKit shims where SwiftUI has no API (idle timer,
orientation lock, haptics).

## Domain Cheat Sheet

- `Shared/Sniffonomics.swift` — the satire "science": line formula, fake
  friends, Nasenlänge (7 cm, Maximilian's eternal lead), 1 cm = 1 km Wrapped
  conversion, destination ladder, points-per-cm for true physical line size,
  pulling seconds per cm, and the amtliche Schulnote 1–6 (one pull within
  1.5 s = 1; every extra attempt and dawdling after zero cost grades).
- `Features/Sniff/` — the core gag: `SniffSessionViewModel` state machine
  (briefing → countdown 3→0 → armed challenge: detection opens 1.5 s before
  zero and STAYS open until the line is pulled — SOUND IS THE ONLY INPUT:
  people pull through a tube, which a touchscreen can't see. Heard pulling
  time clears the line at `Sniffonomics.pullSecondsPerCm`; nothing heard
  for 3 s → „Wir hören nix"; between attempts „nachziehen!"; live
  stopwatch, attempts counted for the grade, 45 s give-up timeout; no mic permission → no session, SniffView points to
  Settings), locked full-screen `SniffSessionView` (idle timer off,
  orientation locked via `OrientationLock`, deferred system gestures,
  hold-the-lock escape; the purple track beside the tobacco box is the
  progress display), `SniffResultOverlay` (shoveler sweep + praise +
  finish time).
- `Core/Audio/SniffDetector.swift` — the pure pull recognizer. Measures
  ONLY the hiss band above 5 kHz (biquad high-pass): airflow lives there,
  voices and bar chatter don't — so a pull still counts under a louder
  voice. Pulling = hiss level ≥ 12 dB above its floor (floor sinks fast,
  rises slowly; ≥ −65 dBFS) for ≥ 0.2 s — fricatives, bumps and ticks are
  too short — then reported buffer by buffer. `just replay [captures…]` runs it offline over
  `.caf` debug captures (`Documents/SniffCaptures/`) and prints the cm a
  capture would clear; without files it runs its self-check.
- `Core/Audio/SniffAudioService.swift` — AVAudioEngine plumbing on a serial
  queue (session activation blocks — never on main), started with the
  countdown; opts into haptics/system sounds during recording, which iOS
  mutes by default.
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
  `Shared/Components/SketchShapes.swift`.
- Persistence: ONE SwiftData model (`SniffSession`), queried directly in
  views; the profile is `@AppStorage` — deliberately no stores. Store raw
  facts (seconds, pulls) and derive the grade (`SniffSession.grade`, fails =
  6); new fields need a default value so existing stores on friends' phones
  migrate automatically.
- Strings: German literals only, no `.xcstrings` entries — private gag app,
  deliberate deviation from the template's de+en rule.
- **NEVER commit without user approval.**

## Versioning

Semantic Versioning via `MARKETING_VERSION` in the Xcode project.
