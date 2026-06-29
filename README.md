# GameConsoleSymbols

A Swift package bundling custom **SF Symbols** for video-game consoles,
publishers and platforms, plus a small lookup that maps a platform (and the
region a copy belongs to) to the right symbol.

The symbols are template SF Symbols, so they tint with `foregroundColor` /
`foregroundStyle` and scale like text.

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/holgerkrupp/GameConsoleSymbols.git", branch: "main")
```

then add `"GameConsoleSymbols"` to your target's dependencies.

## Usage

```swift
import SwiftUI
import GameConsoleSymbols

// Resolve a symbol. `igdbID` is the most reliable key; slug/abbreviation/name
// are tried as a fallback. `variant` disambiguates region-specific hardware.
if let symbol = GameConsoleSymbols.symbol(igdbID: 29, variant: .ntsc) {
    ConsoleSymbolView(symbol: symbol, height: 22)   // renders the Genesis logo
    // symbol.label == "Sega Genesis"  (used as the accessibility label)
}

// Or grab the Image directly:
Image(consoleSymbol: symbol)
    .renderingMode(.template)
    .resizable()
    .scaledToFit()
```

### Region variants

Some IGDB platforms bundle regional hardware under a single entry. Pass a
`RegionVariant` (`.pal`, `.ntsc`, `.japan`) to pick the right logo:

| IGDB id | Platform | `.ntsc` | `.pal` | `.japan` |
|--------:|----------|---------|--------|----------|
| 29 | Sega Mega Drive/Genesis | Genesis | Mega Drive | Mega Drive (JP) |
| 64 | Master System/Mark III | Master System | Master System | Mark III |
| 86 | TurboGrafx-16/PC Engine | TurboGrafx-16 | TurboGrafx-16 | PC Engine |
| 150 | TG-16/PC Engine CD | TurboGrafx-CD | TurboGrafx-CD | PC Engine CD-ROM² |

Map your app's own region type onto `RegionVariant` (e.g. North America →
`.ntsc`, Europe/Australia → `.pal`, Japan → `.japan`).

## Adding a console

Add a row to `igdbMap` in `Sources/GameConsoleSymbols/ConsoleSymbols.swift`,
keyed by the **real IGDB platform id** (verify it — a wrong id shows the wrong
logo). To add new artwork, drop a `*.svg` SF Symbol export into a new
`<name>.symbolset` under `Sources/GameConsoleSymbols/Resources/Symbols.xcassets`.

## Consoles still missing a symbol

The retro line-up is largely complete; known gaps (no artwork yet):

- **Mobile / streaming:** iOS / iPadOS, Steam Deck, Stadia, Amazon Luna, Ouya, Gizmondo
  (Windows, DOS, Mac and Android are present)
- **NEC computers:** PC-8801 (PC-88), PC-9801 (PC-98)
- **Sega:** Sega Pico, Sega Nomad
- **Nintendo:** Nintendo 64DD, Pokémon mini, Game Boy Micro / GBA SP (as distinct logos)
- **Other handhelds / consoles:** Tiger Game.com, Watara Supervision, Mega Duck,
  Casio Loopy / PV-1000, Bandai Playdia, Apple Pippin
- **PC:** Linux

A few symbols are matched by name only (no verified IGDB id yet), so they
resolve via the `name`/`slug` fallback rather than `igdbID`: Evercade
(`evercade`) and Game & Watch (`handheld_game_and_watch`).

## Artwork credit

Symbols are derived from the [game-console / platform icon set](https://wangchujiang.com/#/app).
The package also includes publisher and playlist/theme glyphs from the same set;
only console platforms are wired into the lookup table.
