import SwiftUI

/// Text field with an inline, VoiceOver-announced validation message.
struct ValidatedField: View {
    let title: String
    @Binding var text: String
    let error: String?

    init(_ title: String, text: Binding<String>, error: String?) {
        self.title = title
        self._text = text
        self.error = error
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PassSpacing.xxs) {
            TextField(title, text: $text)
                .accessibilityHint(error ?? "")
            if let error {
                FieldErrorText(message: error)
            }
        }
    }
}

struct FieldErrorText: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.circle")
            .font(PassTypography.footnote)
            .foregroundStyle(PassColors.destructive)
    }
}
