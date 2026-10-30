import SwiftUI

struct PassEmptyState<Actions: View>: View {
    let systemImage: String
    let title: String
    let message: String
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(spacing: PassSpacing.m) {
            Image(systemName: systemImage)
                .font(.system(.largeTitle, weight: .light))
                .foregroundStyle(PassColors.accent)
                .accessibilityHidden(true)
            Text(title)
                .font(PassTypography.displaySmall)
                .foregroundStyle(PassColors.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(PassTypography.callout)
                .foregroundStyle(PassColors.textSecondary)
                .multilineTextAlignment(.center)
            actions()
                .padding(.top, PassSpacing.xs)
        }
        .padding(.horizontal, PassSpacing.screenMargin)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

extension PassEmptyState where Actions == EmptyView {
    init(systemImage: String, title: String, message: String) {
        self.init(systemImage: systemImage, title: title, message: message) { EmptyView() }
    }
}
