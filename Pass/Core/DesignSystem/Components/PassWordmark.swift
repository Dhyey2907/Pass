import SwiftUI

struct PassWordmark: View {
    var font: Font = PassTypography.displaySmall

    var body: some View {
        (Text("pass").foregroundStyle(PassColors.textPrimary)
            + Text(".").foregroundStyle(PassColors.accent))
            .font(font)
            .accessibilityLabel("pass.")
            .accessibilityAddTraits(.isHeader)
    }
}
