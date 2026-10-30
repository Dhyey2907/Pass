import SwiftUI

/// Type scale built on text styles so every token scales with Dynamic Type.
enum PassTypography {
    static let displayLarge = Font.system(.largeTitle, design: .serif, weight: .regular)
    static let display = Font.system(.title, design: .serif, weight: .regular)
    static let displaySmall = Font.system(.title2, design: .serif, weight: .medium)
    static let headline = Font.system(.headline)
    static let body = Font.system(.body)
    static let callout = Font.system(.callout)
    static let footnote = Font.system(.footnote)
    static let button = Font.system(.body, weight: .semibold)
    static let metadata = Font.system(.caption, design: .monospaced, weight: .medium)
}
