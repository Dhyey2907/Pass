import SwiftUI

/// Colour tokens from DESIGN_SPECIFICATION.md. Feature views use the semantic names, not the raw palette.
enum PassColors {
    // MARK: Palette

    static let paper = Color(hex: 0xEDE9DF)
    static let charcoal = Color(hex: 0x292B26)
    static let olive = Color(hex: 0x737B50)
    static let stone = Color(hex: 0xD8D2C4)
    // Spec value #77776D is ~3.7:1 on Paper; darkened to meet WCAG AA (≥4.5:1) for small text.
    static let secondaryText = Color(hex: 0x62625A)
    static let border = Color(hex: 0xD6D1C5)

    // MARK: Semantic

    static let background = paper
    static let surface = stone
    static let textPrimary = charcoal
    static let textSecondary = secondaryText
    static let accent = olive
    static let onAccent = Color.white
    static let divider = border
    static let destructive = Color(hex: 0x9A3B2E)
}
