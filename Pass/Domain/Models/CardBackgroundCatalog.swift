import Foundation

enum CardBackgroundCatalog {
    /// Stored in `Profile.backgroundID` when the user uploaded their own image.
    static let customPhotoID = "custom-photo"

    static func preset(withID id: String) -> CardBackgroundPreset? {
        all.first { $0.id == id }
    }

    static func presets(in category: CardBackgroundCategory) -> [CardBackgroundPreset] {
        all.filter { $0.category == category }
    }

    static let all: [CardBackgroundPreset] = heroes + code + professional + cars

    // Original designs evoking a mood. No characters, logos, or names from existing franchises.
    private static let heroes: [CardBackgroundPreset] = [
        .init(id: "hero-night-guardian", name: "Night Guardian", category: .heroes, tone: .dark,
              fill: .linear([0x0B0F1A, 0x1C2333]), pattern: .rays(count: 18), patternColor: 0x5A6A90, patternOpacity: 0.18,
              symbol: "moon.stars.fill", accent: 0xF2C94C),
        .init(id: "hero-red-alloy", name: "Red Alloy", category: .heroes, tone: .dark,
              fill: .radial([0xA3262A, 0x5E0E12, 0x2A0507]), pattern: .rings(spacing: 18), patternColor: 0xFFD27A, patternOpacity: 0.16,
              symbol: "atom", accent: 0xFFD27A),
        .init(id: "hero-thunder", name: "Thunder", category: .heroes, tone: .dark,
              fill: .linear([0x1B2A4A, 0x3E5C9A]), pattern: .rays(count: 26), patternColor: 0xFFE27A, patternOpacity: 0.1,
              symbol: "bolt.fill", accent: 0xFFE27A),
        .init(id: "hero-star-shield", name: "Star Shield", category: .heroes, tone: .dark,
              fill: .radial([0x2E5AAC, 0x13254F]), pattern: .rings(spacing: 22), patternColor: 0xFFFFFF, patternOpacity: 0.12,
              symbol: "star.fill", accent: 0xFFAAA5),
        .init(id: "hero-scarlet-speed", name: "Scarlet Speed", category: .heroes, tone: .dark,
              fill: .linear([0x9E1019, 0x4A080D]), pattern: .speedLines(seed: 11), patternColor: 0xFFFFFF, patternOpacity: 0.28,
              symbol: "bolt.fill", accent: 0xFFD54F),
        .init(id: "hero-emerald-rage", name: "Emerald Rage", category: .heroes, tone: .dark,
              fill: .linear([0x1E5631, 0x0B2B17]), pattern: .halftone(spacing: 14), patternColor: 0x8BC34A, patternOpacity: 0.3,
              symbol: "burst.fill", accent: 0xC5E1A5),
        .init(id: "hero-web", name: "Web Crawler", category: .heroes, tone: .dark,
              fill: .linear([0xA51C24, 0x1A237E]), pattern: .web(spokes: 16, ringSpacing: 34), patternColor: 0x000000, patternOpacity: 0.35,
              accent: 0xFFCDD2),
        .init(id: "hero-cosmic", name: "Cosmic", category: .heroes, tone: .dark,
              fill: .linear([0x2A0845, 0x5B3A9A]), pattern: .stars(seed: 7), patternColor: 0xFFFFFF, patternOpacity: 0.75,
              symbol: "sparkles", accent: 0xE1BEE7),
        .init(id: "hero-pow", name: "POW!", category: .heroes, tone: .light,
              fill: .linear([0xFFE082, 0xFFC107]), pattern: .halftone(spacing: 12), patternColor: 0xE53935, patternOpacity: 0.3,
              symbol: "burst.fill", accent: 0xA31515),
        .init(id: "hero-frost", name: "Frost Knight", category: .heroes, tone: .dark,
              fill: .linear([0x0D3B66, 0x2F6E99]), pattern: .stars(seed: 21), patternColor: 0xE0F7FA, patternOpacity: 0.5,
              symbol: "snowflake", accent: 0xE0F7FA),
    ]

    private static let code: [CardBackgroundPreset] = [
        .init(id: "code-terminal", name: "Terminal", category: .code, tone: .dark,
              fill: .linear([0x0C0F0A, 0x0C0F0A]), pattern: .codeRain(seed: 3, glyphs: "01{}<>/=;()[]$#"), patternColor: 0x39FF14, patternOpacity: 0.3,
              accent: 0x7CFC8A),
        .init(id: "code-circuit", name: "Circuit Board", category: .code, tone: .dark,
              fill: .linear([0x0E3B2E, 0x082419]), pattern: .circuit(seed: 5), patternColor: 0x4FD1A5, patternOpacity: 0.4,
              symbol: "cpu", accent: 0x9FF2D0),
        .init(id: "code-blueprint", name: "Blueprint", category: .code, tone: .dark,
              fill: .linear([0x123E7C, 0x0D2F5E]), pattern: .grid(spacing: 20), patternColor: 0xFFFFFF, patternOpacity: 0.14,
              symbol: "chevron.left.forwardslash.chevron.right", accent: 0xBBDEFB),
        .init(id: "code-synthwave", name: "Synthwave", category: .code, tone: .dark,
              fill: .linear([0x2B1055, 0x8E2A63]), pattern: .grid(spacing: 26), patternColor: 0xFF7AD9, patternOpacity: 0.25,
              accent: 0xFFC2EC),
        .init(id: "code-binary", name: "Binary", category: .code, tone: .dark,
              fill: .linear([0x0A1931, 0x150E56]), pattern: .codeRain(seed: 9, glyphs: "01"), patternColor: 0x4FC3F7, patternOpacity: 0.3,
              accent: 0xB3E5FC),
        .init(id: "code-dark-mode", name: "Dark Mode", category: .code, tone: .dark,
              fill: .linear([0x1E1E1E, 0x161616]), pattern: .dots(spacing: 16, radius: 1.2), patternColor: 0xFFFFFF, patternOpacity: 0.12,
              symbol: "curlybraces", accent: 0xC3E88D),
        .init(id: "code-monokai", name: "Monokai", category: .code, tone: .dark,
              fill: .linear([0x272822, 0x3E3D32]), pattern: .stripes(angle: -45, width: 3, gap: 22), patternColor: 0xF92672, patternOpacity: 0.22,
              symbol: "chevron.left.forwardslash.chevron.right", accent: 0xE6DB74),
        .init(id: "code-solarized", name: "Solarized", category: .code, tone: .light,
              fill: .linear([0xFDF6E3, 0xF3EAD0]), pattern: .grid(spacing: 22), patternColor: 0x93A1A1, patternOpacity: 0.25,
              symbol: "curlybraces", accent: 0x1E6091),
        .init(id: "code-hex", name: "Hex Grid", category: .code, tone: .dark,
              fill: .linear([0x141E30, 0x243B55]), pattern: .dots(spacing: 14, radius: 1.5), patternColor: 0x64FFDA, patternOpacity: 0.3,
              symbol: "number", accent: 0x64FFDA),
        .init(id: "code-branches", name: "Branches", category: .code, tone: .dark,
              fill: .linear([0x0D1117, 0x161B22]), pattern: .circuit(seed: 42), patternColor: 0xF78166, patternOpacity: 0.35,
              symbol: "arrow.triangle.branch", accent: 0xFFA28B),
    ]

    private static let professional: [CardBackgroundPreset] = [
        .init(id: "pro-linen", name: "Linen", category: .professional, tone: .light,
              fill: .linear([0xF3EFE6, 0xEAE4D7]), pattern: .grid(spacing: 6), patternColor: 0xC9C2B2, patternOpacity: 0.3,
              accent: 0x5E6541),
        .init(id: "pro-charcoal", name: "Charcoal", category: .professional, tone: .dark,
              fill: .linear([0x2B2D28, 0x1C1D1A]), accent: 0xB7BE8F),
        .init(id: "pro-navy-pinstripe", name: "Navy Pinstripe", category: .professional, tone: .dark,
              fill: .linear([0x1B2A41, 0x14203A]), pattern: .stripes(angle: 90, width: 1, gap: 14), patternColor: 0xFFFFFF, patternOpacity: 0.1,
              accent: 0xC9D6EA),
        .init(id: "pro-marble", name: "Soft Marble", category: .professional, tone: .light,
              fill: .radial([0xFFFFFF, 0xE8E4DC]), pattern: .waves(count: 7), patternColor: 0xBDB6A8, patternOpacity: 0.3,
              accent: 0x5E6541),
        .init(id: "pro-olive", name: "Olive Classic", category: .professional, tone: .dark,
              fill: .linear([0x5E6541, 0x3F4429]), pattern: .stripes(angle: 45, width: 1, gap: 16), patternColor: 0xFFFFFF, patternOpacity: 0.06,
              accent: 0xE8EBD5),
        .init(id: "pro-graphite", name: "Graphite", category: .professional, tone: .dark,
              fill: .linear([0x434343, 0x1F1F1F]), pattern: .dots(spacing: 18, radius: 1), patternColor: 0xFFFFFF, patternOpacity: 0.1,
              accent: 0xE0E0E0),
        .init(id: "pro-ivory-dot", name: "Ivory Dot", category: .professional, tone: .light,
              fill: .linear([0xFAF7F0, 0xF2EDE2]), pattern: .dots(spacing: 14, radius: 1.2), patternColor: 0xB8B09E, patternOpacity: 0.5,
              accent: 0x6B5B3E),
        .init(id: "pro-burgundy", name: "Burgundy", category: .professional, tone: .dark,
              fill: .linear([0x5C1A27, 0x3A0F18]), pattern: .stripes(angle: 45, width: 1, gap: 18), patternColor: 0xFFFFFF, patternOpacity: 0.07,
              accent: 0xF1C6CF),
        .init(id: "pro-slate", name: "Slate", category: .professional, tone: .dark,
              fill: .linear([0x3E4A59, 0x2A323D]), pattern: .grid(spacing: 28), patternColor: 0xFFFFFF, patternOpacity: 0.06,
              accent: 0xCFE0F2),
        .init(id: "pro-sand", name: "Sand Dune", category: .professional, tone: .light,
              fill: .linear([0xEFE3CE, 0xDCC9A8]), pattern: .waves(count: 9), patternColor: 0xFFFFFF, patternOpacity: 0.4,
              accent: 0x6B4E1E),
    ]

    private static let cars: [CardBackgroundPreset] = [
        .init(id: "car-racing-stripes", name: "Racing Stripes", category: .cars, tone: .dark,
              fill: .linear([0x0F4C81, 0x0A3460]), pattern: .racingStripes(width: 34, gap: 12), patternColor: 0xFFFFFF, patternOpacity: 0.18,
              accent: 0xFFD166),
        .init(id: "car-checkered", name: "Checkered Flag", category: .cars, tone: .dark,
              fill: .linear([0x1A1A1A, 0x2E2E2E]), pattern: .checker(size: 22), patternColor: 0xFFFFFF, patternOpacity: 0.1,
              symbol: "flag.checkered", accent: 0xFF8A80),
        .init(id: "car-redline", name: "Redline", category: .cars, tone: .dark,
              fill: .linear([0x9E1B1B, 0x1A0000]), pattern: .speedLines(seed: 4), patternColor: 0xFFFFFF, patternOpacity: 0.3,
              symbol: "speedometer", accent: 0xFFCDD2),
        .init(id: "car-carbon", name: "Carbon Fiber", category: .cars, tone: .dark,
              fill: .linear([0x161616, 0x101010]), pattern: .checker(size: 5), patternColor: 0x3A3A3A, patternOpacity: 0.9,
              accent: 0xB0BEC5),
        .init(id: "car-night-drive", name: "Night Drive", category: .cars, tone: .dark,
              fill: .linear([0x0F2027, 0x203A43, 0x2C5364]), pattern: .speedLines(seed: 17), patternColor: 0xFF4081, patternOpacity: 0.3,
              symbol: "car.side.fill", accent: 0x80DEEA),
        .init(id: "car-rally", name: "Rally Orange", category: .cars, tone: .dark,
              fill: .linear([0xB0340B, 0x6E1C04]), pattern: .stripes(angle: -30, width: 18, gap: 42), patternColor: 0xFFFFFF, patternOpacity: 0.1,
              symbol: "steeringwheel", accent: 0xFFE0B2),
        .init(id: "car-racing-green", name: "Racing Green", category: .cars, tone: .dark,
              fill: .linear([0x004225, 0x00291A]), pattern: .racingStripes(width: 26, gap: 10), patternColor: 0xF5E6B8, patternOpacity: 0.2,
              accent: 0xF5E6B8),
        .init(id: "car-tarmac", name: "Tarmac", category: .cars, tone: .dark,
              fill: .linear([0x2E2E2E, 0x222222]), pattern: .stars(seed: 99), patternColor: 0xFFFFFF, patternOpacity: 0.22,
              symbol: "road.lanes", accent: 0xFFEB3B),
        .init(id: "car-neon-tuner", name: "Neon Tuner", category: .cars, tone: .dark,
              fill: .linear([0x12002B, 0x3A0CA3]), pattern: .speedLines(seed: 23), patternColor: 0x00F5D4, patternOpacity: 0.35,
              symbol: "car.fill", accent: 0x00F5D4),
        .init(id: "car-le-mans", name: "Le Mans Blue", category: .cars, tone: .light,
              fill: .linear([0xA9D3EF, 0x8CC2E6]), pattern: .racingStripes(width: 30, gap: 10), patternColor: 0xF26B21, patternOpacity: 0.3,
              accent: 0x0B3D5C),
    ]
}
