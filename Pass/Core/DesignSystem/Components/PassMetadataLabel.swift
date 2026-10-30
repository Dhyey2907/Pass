import SwiftUI

/// Uppercase monospaced label for sparing use on metadata.
struct PassMetadataLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text.uppercased())
            .font(PassTypography.metadata)
            .tracking(1.2)
            .foregroundStyle(PassColors.textSecondary)
    }
}
