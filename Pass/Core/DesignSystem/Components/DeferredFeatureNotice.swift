import SwiftUI

/// Marks a committed feature whose milestone has not been implemented yet,
/// so in-progress builds never present a dead control as working.
struct DeferredFeatureNotice: View {
    let feature: String

    var body: some View {
        HStack(spacing: PassSpacing.xs) {
            Image(systemName: "hammer")
                .accessibilityHidden(true)
            Text("\(feature) is in development")
        }
        .font(PassTypography.footnote)
        .foregroundStyle(PassColors.textSecondary)
        .padding(.horizontal, PassSpacing.s)
        .padding(.vertical, PassSpacing.xs)
        .overlay(
            RoundedRectangle(cornerRadius: PassRadius.control, style: .continuous)
                .strokeBorder(PassColors.divider, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
