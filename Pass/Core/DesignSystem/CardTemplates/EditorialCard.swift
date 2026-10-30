import SwiftUI

struct EditorialCard: View {
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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                CardWordmark(theme: theme)
                Spacer()
                CardMetaText(text: "Identity", theme: theme)
            }
            Spacer(minLength: 20)
            CardPhoto(content: content, theme: theme, size: 76, cornerRadius: 14)
            name(size: 34).padding(.top, 18)
            designation.padding(.top, 6)
            if !content.bio.isEmpty {
                Text(content.bio)
                    .font(.system(size: 12.5))
                    .foregroundStyle(theme.secondary)
                    .lineLimit(3)
                    .padding(.top, 10)
            }
            Spacer(minLength: 16)
            CardRule(theme: theme)
            CardLinesView(lines: content.lines(limit: 4), theme: theme).padding(.top, 14)
        }
        .padding(26)
    }

    private var horizontal: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading) {
                CardPhoto(content: content, theme: theme, size: 96, cornerRadius: 16)
                Spacer()
                CardWordmark(theme: theme)
            }
            VStack(alignment: .leading, spacing: 0) {
                CardMetaText(text: "Identity", theme: theme)
                name(size: 30).padding(.top, 10)
                designation.padding(.top, 6)
                Spacer(minLength: 12)
                CardRule(theme: theme)
                CardLinesView(lines: content.lines(limit: 4), theme: theme).padding(.top, 12)
            }
        }
        .padding(24)
    }

    private func name(size: CGFloat) -> some View {
        Text(content.displayName)
            .font(.system(size: size, weight: .regular, design: .serif))
            .foregroundStyle(theme.primary)
            .lineLimit(2)
            .minimumScaleFactor(0.6)
    }

    @ViewBuilder private var designation: some View {
        if !content.designation.isEmpty {
            Text(content.designation)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.accent)
                .lineLimit(1)
        }
    }
}
