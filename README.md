<div align="center">
  <img src="assets/icon.png" width="217" alt="Sniffify app icon — crowned nose on paper">
  <h1>Sniffify 👃👑</h1>
</div>

> „Maximilian ist dir eine Nasenlänge voraus."

A **satirical iOS gag app** — built as a joke gift for a friend who
enjoys snuff tobacco (Schnupftabak). It recreates, feature for feature, the
fictional app pitched in a German stand-up bit: enter your body data, get your
"official" line, sniff it off the screen at zero, get praised by a flying
crowned nose, lose to Maximilian forever, and receive a Spotify-Wrapped-style
year recap of your Nasenkilometer.

**Credit / inspiration:** the original sketch —
<https://www.instagram.com/p/DbBXNMXi5J2/> — go watch it, the comedian's
hand-drawn mockups are this app's entire design spec. (His material is
deliberately not mirrored in this repo; it's his, not ours.)

**This app is satire.** Adults only, never distributed on any store, and it
works exclusively with legal snuff tobacco. Don't be weird about it.

## Preview

<p>
  <img src="assets/screenshot-1.webp" width="180" alt="Ziehen tab with the official personal line">
  <img src="assets/screenshot-2.webp" width="180" alt="Sniff session countdown with tobacco box, nose track and shoveler">
  <img src="assets/screenshot-3.webp" width="180" alt="Success screen: Du bist spitze, stopwatch, nose trail and confetti">
  <img src="assets/screenshot-4.webp" width="180" alt="Bestenliste podium — Maximilian eine Nasenlänge voraus">
  <img src="assets/screenshot-5.webp" width="180" alt="Sniffify Wrapped year recap with doodle pie chart">
</p>

Demo video (muted, 1.2×): [MP4](assets/demo.mp4) · [WebM](assets/demo.webm)
*(all preview media downscaled and metadata-stripped)*

## The Gag, End to End

1. **Onboarding** — 18+ satire splash (with the rejected „Schneekönig" icon
   gag), then height + weight: science needs data, your line is personal.
2. **Ziehen** — the tobacco goes into a hand-drawn box rendered at **true
   physical size** (points-per-cm), marked out like a construction site. A
   parallel purple **nose track** shows where the nose glides — next to the
   tobacco, not through it. Film-style countdown 3→0, then the challenge:
   the line must be **completely gone** — every dash of the track
   nose-covered — while the mic listens as an anti-cheat gate. A botched
   pull doesn't fail; the stopwatch just runs (finish within 1.5 s of zero
   for „PERFEKT!"). The little shoveler follows your nose the whole way and
   sweeps up on success — „Du bist spitze!". Screen stays awake, rotation is
   locked, system edges are deferred; the only exits are finishing, giving
   up for 45 s, or holding the little lock. A nose fat enough on the glass
   earns „WÜRDIG 👃"; a finger gets called out as cheating. The acoustic
   analysis even guesses Röhrchen vs. Direktzug, and your actual nose path
   is drawn on the result screen as evidence.
3. **Bestenliste** — podium of „Die schnellste Nase". Maximilian is pinned
   exactly one Nasenlänge (7 cm) ahead of you. Forever. That's the joke.
4. **Wrapped** — year totals converted at the official rate of
   1 cm Line = 1 km Fußweg, with a destination ladder ending in Peru, an
   Alleine/Mit-Freunden doodle pie, and share-as-image.
5. **Einstellungen** — profile, data reset, satire small print, and a
   **Debug** section that records the detection window as `.caf` files
   (Files-app accessible) for calibrating the sniff detection.

## Design Language

Everything mimics the sketch's overlays: crumpled-paper background with
procedural creases, wobbly seeded-jitter shapes, iOS built-in handwriting
fonts (Chalkduster / Chalkboard / Bradley Hand), doodle noses everywhere.
Pure SwiftUI — **zero external dependencies**.

## Requirements & Building

- Xcode 26+, iOS 26.0+ deployment target, Swift 6 toolchain
- `just build` (simulator), `just check` (format + build), `just open`
- Mic permission is requested at first „Ziehen"; denial degrades gracefully
  to touch-only judging.

## Calibration Knobs

Real hardware varies — these constants are meant to be tuned with recordings
from Settings → Debug:

| Knob | Where |
|------|-------|
| Spike threshold / absolute gate | `Core/Audio/SniffAudioService.swift` |
| Tube-vs-direct ZCR threshold | `Features/Sniff/SniffSessionViewModel.swift` |
| Coverage %, nose radius, window | `Features/Sniff/SniffSessionViewModel.swift` |
| Points-per-cm (true line size) | `Shared/Sniffonomics.swift` |

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — layers, data flow, patterns
- [CLAUDE.md](CLAUDE.md) — AI assistant guidance

## License

[CC BY-NC-SA 4.0](LICENSE) — share it, tinker with it, remix it, but:

- **Attribution**: credit by linking back to this repository.
- **NonCommercial**: no selling, no commercial use, in any form.
- **ShareAlike**: anything built on it carries these same terms — it stays
  free, forever.

The original comedy sketch this app is based on belongs to its creator —
credit and source: <https://www.instagram.com/p/DbBXNMXi5J2/>.
