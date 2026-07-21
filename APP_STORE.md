# App Store Metadata

App Store Connect metadata for Sniffify in German (primary) and English.

> ⚠️ **Review-risk note:** App Review Guideline 1.4.3 prohibits apps that
> encourage tobacco consumption. Sniffify is satire around legal snuff, but a
> rejection is the realistic default outcome for a public listing.
>
> **Chosen distribution path:** TestFlight **internal testing** (no review)
> plus a TestFlight **public link** for friends — note the public link makes
> the group *external* testers, which triggers **Beta App Review** (lighter
> than full review, but 1.4.3 can still bite there; the honest review notes
> below are written for exactly that conversation).

## App Name

**German:** `Sniffify – Die schnellste Nase`
**English:** `Sniffify – The Fastest Nose`

## German (Primary Language)

### Subtitle (30 characters max)

```
Satirisches Reaktionsspiel
```

### Promotional Text (170 characters max)

```
Leg die amtliche Line, starte den Countdown, zieh bei Null. Mit Bestenliste, Wrapped-Rückblick und Schaufel-Helfer. Ein satirisches Reaktionsspiel für Erwachsene – ab 18.
```

### Description (4000 characters max)

```
Sniffify – Die App für die schnellste Nase

Basierend auf einem Stand-up-Gag: die App, die es nie hätte geben dürfen — jetzt gibt es sie. Ein satirisches Reaktionsspiel für Erwachsene, gebaut für den Abend mit Freunden.

DEINE AMTLICHE LINE
• Größe und Gewicht eingeben — die Wissenschaft braucht Daten
• Deine persönliche Line wird amtlich berechnet und in ECHTER GRÖSSE angezeigt (zentimetergenau, Bildschirm-Physik sei Dank)
• Wie eine Baustelle abgesteckt, daneben die lila Nasen-Spur

DIE CHALLENGE
• Film-Countdown 3… 2… 1… ZIEH!
• Die Line muss KOMPLETT weg — jeder Strich zählt
• Verpatzter Zug? Kein Problem: Die Stoppuhr läuft einfach weiter
• Unter 1,5 Sekunden: PERFEKT!
• Mikrofon-Analyse als Schummel-Schutz
• Nasenerkennung: eine echte Nase auf dem Glas ist WÜRDIG, ein Finger wird öffentlich beschämt
• Der kleine Schaufel-Helfer begleitet jeden Zug und räumt hinterher auf

BESTENLISTE
• Podium der schnellsten Nasen
• Maximilian ist dir immer genau eine Nasenlänge voraus. Immer.

SNIFFIFY WRAPPED
• Jahresrückblick: Lines, Gesamtlänge, schnellste Nase
• Amtliche Umrechnung: 1 cm Line = 1 km Fußweg — wie weit wärst du gekommen?
• Teilbar als Bild

PRIVATSPHÄRE
• Kein Tracking, keine Analytics, kein Account
• Alle Daten bleiben auf dem Gerät
• Mikrofon nur während des Zieh-Fensters aktiv, nichts verlässt das Gerät

Sniffify ist reine Satire unter Erwachsenen (ab 18) und thematisiert ausschließlich legalen Schnupftabak. Nichts wird verkauft, beworben oder ernst gemeint.
```

### Keywords (100 characters max, comma-separated)

```
Satire,Party,Gag,Spiel,Reaktion,Timer,Nase,Bestenliste,Challenge,Freunde
```

## English

### Subtitle (30 characters max)

```
A satirical reaction game
```

### Promotional Text (170 characters max)

```
Lay the official line, start the countdown, pull at zero. Leaderboard, Wrapped recap, and a shovel buddy. A satirical reaction game for adults – 18+.
```

### Description (4000 characters max)

```
Sniffify – The App for the Fastest Nose

Based on a stand-up comedy bit: the app that should never have existed — now it does. A satirical reaction game for adults, built for evenings with friends.

YOUR OFFICIAL LINE
• Enter height and weight — science needs data
• Your personal line is officially calculated and rendered at TRUE physical size (centimeter-accurate, thanks to screen physics)
• Marked out like a construction site, with the purple nose track alongside

THE CHALLENGE
• Film-style countdown 3… 2… 1… PULL!
• The line must be COMPLETELY gone — every dash counts
• Botched the pull? No problem: the stopwatch just keeps running
• Under 1.5 seconds: PERFEKT!
• Microphone analysis as an anti-cheat gate
• Nose detection: a real nose on the glass is WORTHY, a finger gets publicly shamed
• The little shovel buddy follows every pull and cleans up afterwards

LEADERBOARD
• Podium of the fastest noses
• Maximilian is always exactly one nose-length ahead of you. Always.

SNIFFIFY WRAPPED
• Year in review: lines, total length, fastest nose
• Official conversion: 1 cm of line = 1 km on foot — how far would you have walked?
• Shareable as an image

PRIVACY
• No tracking, no analytics, no account
• All data stays on your device
• Microphone active only during the pull window; nothing leaves the device

Sniffify is pure satire for adults (18+), themed exclusively around legal snuff tobacco. Nothing is sold, advertised, or meant seriously.
```

### Keywords (100 characters max, comma-separated)

```
satire,party,gag,game,reaction,timer,nose,leaderboard,challenge,friends
```

## Categories

| Slot      | Category             |
| --------- | -------------------- |
| Primary   | Entertainment        |
| Secondary | Games → Party        |

(Entertainment-first frames the app as satire/novelty; avoid Lifestyle —
it would frame it as a real tobacco-companion app.)

## Age Rating

ASC questionnaire: **Tobacco or Drug Use or References → Frequent/Intense**
→ resulting rating **17+**. Do not understate this; it is the honest answer
and the only defensible one in review.

## URLs (App Store Connect)

| Field              | Value                                                         |
| ------------------ | ------------------------------------------------------------- |
| App Store listing  | — (fill in after first approval)                              |
| Marketing URL      | https://github.com/philippobol/Sniffify                       |
| Support URL        | https://github.com/philippobol/Sniffify/issues                |
| Privacy Policy URL | https://github.com/philippobol/Sniffify/blob/main/PRIVACY.md |

## What's New / Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## Screenshots

ASC-ready PNGs live in **`assets/app-store/`** (01-ziehen … 05-wrapped,
**1284 × 2778** — the 6.5" slot ASC demands for this app record).

> Note: these are upscaled from 540 px working copies (the native-resolution
> originals no longer exist). Fine as placeholders and for TestFlight; for a
> real App Store listing, re-capture natively on device and replace them.

### iPhone

| Device                    | Size        | Required |
| ------------------------- | ----------- | -------- |
| 6.5" class (14 Plus etc.) | 1284 x 2778 | Yes      |

### iPad

| Device            | Size        | Required                     |
| ----------------- | ----------- | ---------------------------- |
| iPad Pro 13" (M4) | 2064 x 2752 | Yes (target supports iPad)   |

Real simulator captures live in `assets/app-store/ipad-01-splash.png` and
`ipad-02-ziehen.png` (native 2064 × 2752, metadata-stripped).

### Suggested Screenshot Scenes

1. **Ziehen** — the official line with builders, cones, and formula
2. **Session** — countdown with tobacco box, nose track, shovel buddy
3. **Erfolg** — „Du bist spitze!" with stopwatch, nose trail, confetti
4. **Bestenliste** — podium, Maximilian eine Nasenlänge voraus
5. **Wrapped** — year recap with doodle pie chart

## App Store Icon

- **Size:** 1024 x 1024 px (source: `Sniffify/Assets.xcassets/AppIcon.appiconset/AppIcon.png`)
- **Format:** PNG (no alpha)
- **Corner radius:** Applied automatically by App Store

## Review Notes

```
Sniffify is a satirical party app for adults, based on a German stand-up
comedy bit. It is a timer/reaction game themed around SNUFF TOBACCO
(Schnupftabak), a legal smokeless tobacco product traditional in
Germany/Austria/Bavaria.

- The app sells nothing, contains no ads, no purchases, and no links to
  tobacco vendors.
- Age rating is 17+ with frequent/intense tobacco references declared.
- The microphone is used exclusively during the user-started countdown
  window to detect a sharp inhale as part of the game; audio is processed
  on-device and never stored or transmitted (an optional debug recording
  feature writes files only to the user's local Documents folder).
- No account, no tracking, no data collection.

The content is comedic satire; the app mocks tobacco rituals rather than
promoting them.
```

_Last updated: v1.0.0_
