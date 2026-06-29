//
//  ConsoleSymbols.swift
//  GameConsoleSymbols
//
//  Maps a video-game platform (+ the region a copy belongs to) to a custom
//  SF Symbol shipped in this package's `Symbols.xcassets`.
//
//  The lookup is deliberately decoupled from any data model: callers pass the
//  IGDB platform id and/or text identifiers plus an optional `RegionVariant`.
//
//  Matching strategy (most reliable first):
//   1. IGDB numeric platform id.
//   2. Normalized slug / abbreviation / name fallback.
//
//  Some IGDB platforms bundle several regional hardware variants under one
//  entry (e.g. "Sega Mega Drive/Genesis"). For those we branch on the supplied
//  `RegionVariant` so a US copy shows the Genesis logo while an EU copy shows
//  the Mega Drive logo.
//

import Foundation

/// A console symbol: the asset-catalog name plus an accessibility label.
public struct ConsoleSymbol: Equatable, Sendable {
    /// Name of the symbol set inside the package's asset catalog
    /// (e.g. `"nintendo_switch"`). Load with `Image(consoleSymbol:)`.
    public let assetName: String
    /// Human readable name, suitable as the accessibility / VoiceOver label.
    public let label: String

    public init(assetName: String, label: String) {
        self.assetName = assetName
        self.label = label
    }
}

/// The hardware-variant grouping used to pick a region-specific symbol.
///
/// Map your own region representation onto this when calling
/// ``GameConsoleSymbols/symbol(igdbID:slug:abbreviation:name:variant:)``.
public enum RegionVariant: Sendable {
    case pal      // Europe / Australia / New Zealand / Brazil / …
    case ntsc     // North America
    case japan    // Japan
}

/// One row in the lookup table: a default symbol plus optional per-region overrides.
struct SymbolEntry {
    let base: ConsoleSymbol
    let variants: [RegionVariant: ConsoleSymbol]

    init(_ asset: String, _ label: String, variants: [RegionVariant: ConsoleSymbol] = [:]) {
        self.base = ConsoleSymbol(assetName: asset, label: label)
        self.variants = variants
    }

    func resolve(_ variant: RegionVariant?) -> ConsoleSymbol {
        if let variant, let match = variants[variant] {
            return match
        }
        return base
    }
}

public enum GameConsoleSymbols {

    // MARK: - Public API

    /// Returns the console symbol for a platform, taking an optional region
    /// variant into account for hardware that shares one IGDB entry.
    ///
    /// - Parameters:
    ///   - igdbID: The IGDB platform id (most reliable key).
    ///   - slug: IGDB platform slug (fallback).
    ///   - abbreviation: Platform abbreviation, e.g. `"SNES"` (fallback).
    ///   - name: Full platform name, e.g. `"Super Nintendo …"` (fallback).
    ///   - variant: Region grouping used to disambiguate variant hardware.
    /// - Returns: A matching ``ConsoleSymbol`` or `nil` when none is known.
    public static func symbol(igdbID: Int? = nil,
                              slug: String? = nil,
                              abbreviation: String? = nil,
                              name: String? = nil,
                              variant: RegionVariant? = nil) -> ConsoleSymbol? {
        // 1) IGDB numeric platform id is the most stable key.
        if let igdbID, let entry = igdbMap[igdbID] {
            return entry.resolve(variant)
        }

        // 2) Fall back to normalized text matching.
        for candidate in [slug, abbreviation, name] {
            if let candidate, !candidate.isEmpty,
               let entry = nameMap[normalize(candidate)] {
                return entry.resolve(variant)
            }
        }
        return nil
    }

    static func normalize(_ string: String) -> String {
        string.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    // MARK: - IGDB id → symbol

    /// Keyed by IGDB platform id.
    static let igdbMap: [Int: SymbolEntry] = [
        // ── Nintendo home consoles ──────────────────────────────
        18:  SymbolEntry("nintendo_nes", "Nintendo Entertainment System"),
        99:  SymbolEntry("nintendo_famicom", "Nintendo Famicom"),
        51:  SymbolEntry("nintendo_famicom_disksystem", "Famicom Disk System"),
        19:  SymbolEntry("nintendo_snes", "Super Nintendo Entertainment System"),
        58:  SymbolEntry("nintendo_super_famicom", "Super Famicom"),
        4:   SymbolEntry("nintendo_64", "Nintendo 64"),
        21:  SymbolEntry("nintendo_gamecube", "Nintendo GameCube"),
        5:   SymbolEntry("nintendo_wii", "Nintendo Wii"),
        41:  SymbolEntry("nintendo_wiiu", "Nintendo Wii U"),
        130: SymbolEntry("nintendo_switch", "Nintendo Switch"),
        508: SymbolEntry("nintendo_switch_2", "Nintendo Switch 2"),

        // ── Nintendo handhelds ──────────────────────────────────
        33:  SymbolEntry("nintendo_gameboy", "Game Boy"),
        22:  SymbolEntry("nintendo_gameboy_color", "Game Boy Color"),
        24:  SymbolEntry("nintendo_gameboy_advance", "Game Boy Advance"),
        20:  SymbolEntry("nintendo_ds", "Nintendo DS"),
        159: SymbolEntry("nintendo_dsi", "Nintendo DSi"),
        37:  SymbolEntry("nintendo_3ds", "Nintendo 3DS"),
        87:  SymbolEntry("nintendo_virtualboy", "Virtual Boy"),

        // ── Sony PlayStation ────────────────────────────────────
        7:   SymbolEntry("playstation_ps_compact", "PlayStation"),
        8:   SymbolEntry("playstation_ps2_compact", "PlayStation 2"),
        9:   SymbolEntry("playstation_ps3_compact", "PlayStation 3"),
        48:  SymbolEntry("playstation_ps4_compact", "PlayStation 4"),
        167: SymbolEntry("playstation_ps5_compact", "PlayStation 5"),
        38:  SymbolEntry("playstation_psp", "PlayStation Portable"),
        46:  SymbolEntry("playstation_vita", "PlayStation Vita"),

        // ── Microsoft Xbox ──────────────────────────────────────
        11:  SymbolEntry("xbox_original", "Xbox"),
        12:  SymbolEntry("xbox_360", "Xbox 360"),
        49:  SymbolEntry("xbox_one", "Xbox One"),
        169: SymbolEntry("xbox_series", "Xbox Series X|S"),

        // ── Sega (region-variant entries) ───────────────────────
        84:  SymbolEntry("sega_sg1000", "Sega SG-1000"),
        64:  SymbolEntry("sega_master_system", "Sega Master System",
                         variants: [.japan: ConsoleSymbol(assetName: "sega_markiii", label: "Sega Mark III")]),
        29:  SymbolEntry("sega_megadrive", "Sega Mega Drive",
                         variants: [
                            .ntsc:  ConsoleSymbol(assetName: "sega_genesis", label: "Sega Genesis"),
                            .pal:   ConsoleSymbol(assetName: "sega_megadrive", label: "Sega Mega Drive"),
                            .japan: ConsoleSymbol(assetName: "sega_megadrive_japan", label: "Sega Mega Drive (Japan)")
                         ]),
        30:  SymbolEntry("sega_32x", "Sega 32X"),
        78:  SymbolEntry("sega_cd", "Sega CD / Mega-CD"),
        32:  SymbolEntry("sega_saturn", "Sega Saturn"),
        23:  SymbolEntry("sega_dreamcast", "Sega Dreamcast"),
        35:  SymbolEntry("sega_gamegear", "Sega Game Gear"),

        // ── NEC (region-variant entries) ────────────────────────
        86:  SymbolEntry("nec_pcengine", "PC Engine",
                         variants: [
                            .ntsc: ConsoleSymbol(assetName: "nec_turbografx16", label: "TurboGrafx-16"),
                            .pal:  ConsoleSymbol(assetName: "nec_turbografx16", label: "TurboGrafx-16"),
                            .japan: ConsoleSymbol(assetName: "nec_pcengine", label: "PC Engine")
                         ]),
        150: SymbolEntry("nec_pcengine_cdrom", "PC Engine CD-ROM²",
                         variants: [
                            .ntsc: ConsoleSymbol(assetName: "nec_turbografxcd", label: "TurboGrafx-CD"),
                            .pal:  ConsoleSymbol(assetName: "nec_turbografxcd", label: "TurboGrafx-CD"),
                            .japan: ConsoleSymbol(assetName: "nec_pcengine_cdrom", label: "PC Engine CD-ROM²")
                         ]),
        128: SymbolEntry("nec_pcengine_supergrafx", "PC Engine SuperGrafx"),
        274: SymbolEntry("nec_pcfx", "PC-FX"),

        // ── SNK ─────────────────────────────────────────────────
        80:  SymbolEntry("snk_neogeo", "Neo Geo"),
        136: SymbolEntry("snk_neogeo_cd", "Neo Geo CD"),
        119: SymbolEntry("snk_neogeo_pocket", "Neo Geo Pocket"),
        120: SymbolEntry("snk_neogeo_pocket_color", "Neo Geo Pocket Color"),

        // ── Atari ───────────────────────────────────────────────
        59:  SymbolEntry("atari_2600", "Atari 2600"),
        66:  SymbolEntry("atari_5200", "Atari 5200"),
        60:  SymbolEntry("atari_7800", "Atari 7800"),
        65:  SymbolEntry("atari_800", "Atari 8-bit"),
        63:  SymbolEntry("atari_st", "Atari ST"),
        61:  SymbolEntry("atari_lynx", "Atari Lynx"),
        62:  SymbolEntry("atari_jaguar", "Atari Jaguar"),

        // ── Bandai ──────────────────────────────────────────────
        57:  SymbolEntry("bandai_wonderswan", "WonderSwan"),
        123: SymbolEntry("bandai_wonderswan_color", "WonderSwan Color"),

        // ── Other consoles ──────────────────────────────────────
        50:  SymbolEntry("3do", "3DO"),
        117: SymbolEntry("philips_cdi", "Philips CD-i"),
        68:  SymbolEntry("coleco_vision", "ColecoVision"),
        67:  SymbolEntry("mattel_intellivision", "Intellivision"),
        70:  SymbolEntry("vectrex", "Vectrex"),
        127: SymbolEntry("fairchild_channelf", "Fairchild Channel F"),
        88:  SymbolEntry("magnavox_odyssey", "Magnavox Odyssey"),
        133: SymbolEntry("philips_videopac", "Philips Videopac G7000"),

        // ── Home computers ──────────────────────────────────────
        15:  SymbolEntry("commodore_64", "Commodore 64"),
        16:  SymbolEntry("commodore_amiga", "Commodore Amiga"),
        114: SymbolEntry("commodore_amiga_cd32", "Amiga CD32"),
        71:  SymbolEntry("commodore_vic20", "Commodore VIC-20"),
        121: SymbolEntry("sharp_x68000", "Sharp X68000"),
        77:  SymbolEntry("sharp_x1", "Sharp X1"),
        26:  SymbolEntry("sinclair_zxspectrum", "ZX Spectrum"),
        25:  SymbolEntry("amstrad_cpc", "Amstrad CPC"),
        69:  SymbolEntry("bbc_micro", "BBC Micro"),
        116: SymbolEntry("acorn_archimedes", "Acorn Archimedes"),
        75:  SymbolEntry("apple-ii", "Apple II"),
        27:  SymbolEntry("msx", "MSX"),
        53:  SymbolEntry("msx2", "MSX2"),
        14:  SymbolEntry("apple_macos", "macOS"),
        13:  SymbolEntry("ms-dos", "MS-DOS"),
        6:   SymbolEntry("windows", "PC (Windows)"),

        // ── Mobile / arcade ─────────────────────────────────────
        34:  SymbolEntry("android_2019", "Android"),
        52:  SymbolEntry("arcade", "Arcade"),
    ]

    // MARK: - Normalized name → symbol (fallback for non-IGDB sources)

    static let nameMap: [String: SymbolEntry] = [
        "nintendoswitch": SymbolEntry("nintendo_switch", "Nintendo Switch"),
        "switch": SymbolEntry("nintendo_switch", "Nintendo Switch"),
        "nintendoswitch2": SymbolEntry("nintendo_switch_2", "Nintendo Switch 2"),
        "switch2": SymbolEntry("nintendo_switch_2", "Nintendo Switch 2"),
        "wiiu": SymbolEntry("nintendo_wiiu", "Nintendo Wii U"),
        "wii": SymbolEntry("nintendo_wii", "Nintendo Wii"),
        "nintendo64": SymbolEntry("nintendo_64", "Nintendo 64"),
        "n64": SymbolEntry("nintendo_64", "Nintendo 64"),
        "gamecube": SymbolEntry("nintendo_gamecube", "Nintendo GameCube"),
        "gc": SymbolEntry("nintendo_gamecube", "Nintendo GameCube"),
        "nes": SymbolEntry("nintendo_nes", "Nintendo Entertainment System"),
        "snes": SymbolEntry("nintendo_snes", "Super Nintendo Entertainment System"),
        "famicom": SymbolEntry("nintendo_famicom", "Nintendo Famicom"),
        "superfamicom": SymbolEntry("nintendo_super_famicom", "Super Famicom"),
        "gameboy": SymbolEntry("nintendo_gameboy", "Game Boy"),
        "gameboycolor": SymbolEntry("nintendo_gameboy_color", "Game Boy Color"),
        "gameboyadvance": SymbolEntry("nintendo_gameboy_advance", "Game Boy Advance"),
        "gba": SymbolEntry("nintendo_gameboy_advance", "Game Boy Advance"),
        "nintendods": SymbolEntry("nintendo_ds", "Nintendo DS"),
        "nintendo3ds": SymbolEntry("nintendo_3ds", "Nintendo 3DS"),
        "virtualboy": SymbolEntry("nintendo_virtualboy", "Virtual Boy"),

        "playstation": SymbolEntry("playstation_ps_compact", "PlayStation"),
        "ps1": SymbolEntry("playstation_ps_compact", "PlayStation"),
        "psx": SymbolEntry("playstation_ps_compact", "PlayStation"),
        "playstation2": SymbolEntry("playstation_ps2_compact", "PlayStation 2"),
        "ps2": SymbolEntry("playstation_ps2_compact", "PlayStation 2"),
        "playstation3": SymbolEntry("playstation_ps3_compact", "PlayStation 3"),
        "ps3": SymbolEntry("playstation_ps3_compact", "PlayStation 3"),
        "playstation4": SymbolEntry("playstation_ps4_compact", "PlayStation 4"),
        "ps4": SymbolEntry("playstation_ps4_compact", "PlayStation 4"),
        "playstation5": SymbolEntry("playstation_ps5_compact", "PlayStation 5"),
        "ps5": SymbolEntry("playstation_ps5_compact", "PlayStation 5"),
        "psp": SymbolEntry("playstation_psp", "PlayStation Portable"),
        "psvita": SymbolEntry("playstation_vita", "PlayStation Vita"),
        "vita": SymbolEntry("playstation_vita", "PlayStation Vita"),

        "xbox": SymbolEntry("xbox_original", "Xbox"),
        "xbox360": SymbolEntry("xbox_360", "Xbox 360"),
        "xboxone": SymbolEntry("xbox_one", "Xbox One"),
        "xboxseriesxs": SymbolEntry("xbox_series", "Xbox Series X|S"),
        "xboxseriesx": SymbolEntry("xbox_series", "Xbox Series X|S"),

        "segamegadrivegenesis": SymbolEntry("sega_megadrive", "Sega Mega Drive",
            variants: [
                .ntsc:  ConsoleSymbol(assetName: "sega_genesis", label: "Sega Genesis"),
                .japan: ConsoleSymbol(assetName: "sega_megadrive_japan", label: "Sega Mega Drive (Japan)")
            ]),
        "genesis": SymbolEntry("sega_genesis", "Sega Genesis"),
        "megadrive": SymbolEntry("sega_megadrive", "Sega Mega Drive"),
        "segasaturn": SymbolEntry("sega_saturn", "Sega Saturn"),
        "saturn": SymbolEntry("sega_saturn", "Sega Saturn"),
        "dreamcast": SymbolEntry("sega_dreamcast", "Sega Dreamcast"),
        "gamegear": SymbolEntry("sega_gamegear", "Sega Game Gear"),
        "mastersystem": SymbolEntry("sega_master_system", "Sega Master System"),
        "sega32x": SymbolEntry("sega_32x", "Sega 32X"),
        "segacd": SymbolEntry("sega_cd", "Sega CD"),

        "neogeo": SymbolEntry("snk_neogeo", "Neo Geo"),
        "turbografx16": SymbolEntry("nec_turbografx16", "TurboGrafx-16"),
        "pcengine": SymbolEntry("nec_pcengine", "PC Engine"),

        "evercade": SymbolEntry("evercade", "Evercade"),
        "3do": SymbolEntry("3do", "3DO"),
        "commodore64": SymbolEntry("commodore_64", "Commodore 64"),
        "c64": SymbolEntry("commodore_64", "Commodore 64"),
        "amiga": SymbolEntry("commodore_amiga", "Commodore Amiga"),
        "msx": SymbolEntry("msx", "MSX"),
        "arcade": SymbolEntry("arcade", "Arcade"),
        "mac": SymbolEntry("apple_macos", "macOS"),
        "macos": SymbolEntry("apple_macos", "macOS"),
        "pcmicrosoftwindows": SymbolEntry("windows", "PC (Windows)"),
        "pc": SymbolEntry("windows", "PC (Windows)"),
        "windows": SymbolEntry("windows", "Windows"),
        "dos": SymbolEntry("ms-dos", "MS-DOS"),
        "android": SymbolEntry("android_2019", "Android"),
    ]
}
