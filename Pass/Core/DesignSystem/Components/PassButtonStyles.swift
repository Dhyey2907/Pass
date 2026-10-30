import SwiftUI

struct PassPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PassTypography.button)
            .foregroundStyle(PassColors.onAccent)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, PassSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: PassRadius.button, style: .continuous)
                    .fill(PassColors.accent)
            )
            .opacity(isEnabled ? (configuration.isPressed ? 0.82 : 1) : 0.45)
            .contentShape(RoundedRectangle(cornerRadius: PassRadius.button, style: .continuous))
    }
}

struct PassSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PassTypography.button)
            .foregroundStyle(PassColors.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, PassSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: PassRadius.button, style: .continuous)
                    .fill(configuration.isPressed ? PassColors.surface : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PassRadius.button, style: .continuous)
                    .strokeBorder(PassColors.divider, lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : 0.45)
            .contentShape(RoundedRectangle(cornerRadius: PassRadius.button, style: .continuous))
    }
}

extension ButtonStyle where Self == PassPrimaryButtonStyle {
    static var passPrimary: PassPrimaryButtonStyle { PassPrimaryButtonStyle() }
}

extension ButtonStyle where Self == PassSecondaryButtonStyle {
    static var passSecondary: PassSecondaryButtonStyle { PassSecondaryButtonStyle() }
}
