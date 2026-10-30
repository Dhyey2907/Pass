import SwiftUI

struct EssentialCard: View {
    let content: CardContent
    let orientation: CardOrientation
    let theme: CardTheme

    var body: some View {
        switch orientation {
        case .vertical: vertical
        case .horizontal: horizontal
        }
    }

    private var vertical: some View {
        VStack(spacing: 0) {
            CardPhoto(content: content, theme: theme, size: 96).padding(.top, 12)
            name(size: 26).multilineTextAlignment(.center).padding(.top, 20)
            designation.padding(.top, 6)
            if !content.bio.isEmpty {
                Text(content.bio)
                    .font(.system(size: 12.5))
                    .foregroundStyle(theme.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.top, 12)
            }
            Spacer(minLength: 16)
            CardRule(theme: theme)
            CardLinesView(lines: content.lines(limit: 4), theme: theme, monospaced: false)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 14)
            HStack {
                Spacer()
                CardWordmark(theme: theme)
            }
            .padding(.top, 14)
        }
        .padding(26)
    }

    private var horizontal: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                name(size: 26)
                designation.padding(.top, 6)
                Spacer(minLength: 12)
                CardLinesView(lines: content.lines(limit: 4), theme: theme, monospaced: false)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing) {
                CardPhoto(content: content, theme: theme, size: 88)
                Spacer()
                CardWordmark(theme: theme)
            }
        }
        .padding(24)
    }

    private func name(size: CGFloat) -> some View {
        Text(content.displayName)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(theme.primary)
            .lineLimit(2)
            .minimumScaleFactor(0.6)
    }

    @ViewBuilder private var designation: some View {
        if !content.designation.isEmpty {
            Text(content.designation)
                .font(.system(size: 14))
                .foregroundStyle(theme.secondary)
                .lineLimit(1)
        }
    }
}
