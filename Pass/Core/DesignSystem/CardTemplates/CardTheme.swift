import SwiftUI

/// Fixed palettes for card artwork. Every text/background pair meets WCAG AA.
struct CardTheme {
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let rule: Color
    let border: Color?

    static let editorial = CardTheme(
        background: PassColors.paper,
        primary: PassColors.charcoal,
        secondary: PassColors.secondaryText,
        accent: PassColors.olive,
        rule: PassColors.border,
        border: PassColors.border
    )

    static let essential = CardTheme(
        background: Color(hex: 0xFAF8F3),
        primary: PassColors.charcoal,
        secondary: PassColors.secondaryText,
        accent: PassColors.olive,
        rule: Color(hex: 0xE4DFD4),
        border: PassColors.border
    )

    static let contrast = CardTheme(
        background: PassColors.charcoal,
        primary: PassColors.paper,
        secondary: Color(hex: 0xB9B5A8),
        accent: Color(hex: 0xB7BE8F),
        rule: Color(hex: 0x45473F),
        border: nil
    )
}

extension CardTheme {
    /// Text colours for a card drawn over a background. Photos always get a dark scrim and light text.
    static func over(_ background: ResolvedCardBackground) -> CardTheme {
        switch background {
        case .photo:
            return overDark(accent: Color(hex: 0xD4DAB0))
        case .preset(let preset):
            let accent = Color(hex: preset.accent)
            return preset.tone == .dark ? overDark(accent: accent) : overLight(accent: accent)
        }
    }

    private static func overDark(accent: Color) -> CardTheme {
        CardTheme(
            background: PassColors.charcoal,
            primary: Color(hex: 0xF7F4EC),
            secondary: Color(hex: 0xDAD6CB),
            accent: accent,
            rule: Color.white.opacity(0.25),
            border: nil
        )
    }

    private static func overLight(accent: Color) -> CardTheme {
        CardTheme(
            background: PassColors.paper,
            primary: PassColors.charcoal,
            secondary: Color(hex: 0x4A4A43),
            accent: accent,
            rule: Color.black.opacity(0.15),
            border: PassColors.border
        )
    }
}

enum CardMetrics {
    /// Canonical artboard sizes (ISO ID-1 proportions). Cards are laid out at this size and scaled.
    static func canonicalSize(for orientation: CardOrientation) -> CGSize {
        switch orientation {
        case .vertical: CGSize(width: 340, height: 540)
        case .horizontal: CGSize(width: 540, height: 340)
        }
    }
}
