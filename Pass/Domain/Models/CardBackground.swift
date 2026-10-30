import Foundation

enum CardBackgroundCategory: String, CaseIterable, Identifiable {
    case heroes
    case code
    case professional
    case cars

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .heroes: "Heroes"
        case .code: "Code"
        case .professional: "Professional"
        case .cars: "Cars"
        }
    }
}

enum BackgroundPattern: Equatable {
    case stripes(angle: Double, width: Double, gap: Double)
    case racingStripes(width: Double, gap: Double)
    case dots(spacing: Double, radius: Double)
    case grid(spacing: Double)
    case rays(count: Int)
    case web(spokes: Int, ringSpacing: Double)
    case halftone(spacing: Double)
    case rings(spacing: Double)
    case waves(count: Int)
    case checker(size: Double)
    case circuit(seed: UInt64)
    case codeRain(seed: UInt64, glyphs: String)
    case speedLines(seed: UInt64)
    case stars(seed: UInt64)
}

/// A built-in card background, drawn in code so it stays sharp at any export size and ships no third-party artwork.
struct CardBackgroundPreset: Identifiable, Equatable {
    enum Tone: Equatable {
        /// Light text on a dark background.
        case dark
        /// Dark text on a light background.
        case light
    }

    enum Fill: Equatable {
        case linear([UInt32])
        case radial([UInt32])
    }

    let id: String
    let name: String
    let category: CardBackgroundCategory
    let tone: Tone
    let fill: Fill
    var pattern: BackgroundPattern?
    var patternColor: UInt32 = 0xFFFFFF
    var patternOpacity: Double = 0.2
    var symbol: String?
    /// Designation and accent-bar colour; chosen per preset to stay legible on its fill.
    let accent: UInt32
}
