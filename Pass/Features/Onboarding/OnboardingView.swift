import SwiftUI

struct OnboardingView: View {
    /// Called with `true` when the user chose to create a card right away.
    let onFinish: (_ createCard: Bool) -> Void
    @State private var step = 0

    private let steps: [OnboardingStep] = [
        OnboardingStep(symbol: "person.text.rectangle", title: "Make an impression.", message: "Design a card that feels like you: your name, your role, your links and the projects you're proud of."),
        OnboardingStep(symbol: "qrcode", title: "Leave a connection.", message: "Share your card as an image now. Scan-to-connect is coming next."),
        OnboardingStep(symbol: "lock", title: "Yours, on your terms.", message: "No account needed. Everything stays on this iPhone until you choose to publish."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                PassWordmark()
                Spacer()
                Button("Skip") { onFinish(false) }
                    .foregroundStyle(PassColors.textSecondary)
                    .frame(minWidth: PassSpacing.minimumTouchTarget, minHeight: PassSpacing.minimumTouchTarget)
            }
            .padding(.horizontal, PassSpacing.screenMargin)

            TabView(selection: $step) {
                ForEach(steps.indices, id: \.self) { index in
                    OnboardingStepView(step: steps[index]).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Group {
                if step < steps.count - 1 {
                    Button("Continue") { withAnimation { step += 1 } }
                        .buttonStyle(.passPrimary)
                } else {
                    Button("Create your Pass") { onFinish(true) }
                        .buttonStyle(.passPrimary)
                }
            }
            .padding(.horizontal, PassSpacing.screenMargin)
            .padding(.bottom, PassSpacing.l)
        }
        .background(PassColors.background)
    }
}

private struct OnboardingStep {
    let symbol: String
    let title: String
    let message: String
}

private struct OnboardingStepView: View {
    let step: OnboardingStep

    var body: some View {
        VStack(alignment: .leading, spacing: PassSpacing.m) {
            Spacer()
            Image(systemName: step.symbol)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(PassColors.accent)
                .accessibilityHidden(true)
            Text(step.title)
                .font(PassTypography.displayLarge)
                .foregroundStyle(PassColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(step.message)
                .font(PassTypography.body)
                .foregroundStyle(PassColors.textSecondary)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PassSpacing.screenMargin)
    }
}

#Preview {
    OnboardingView { _ in }
}
