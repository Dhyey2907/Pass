import SwiftUI

struct ContrastCard: View {
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
                CardPhoto(content: content, theme: theme, size: 56)
            }
            Spacer(minLength: 16)
            accentBar
            name(size: 40).padding(.top, 16)
            designation.padding(.top, 8)
            if !content.bio.isEmpty {
                Text(content.bio)
                    .font(.system(size: 12.5))
                    .foregroundStyle(theme.secondary)
                    .lineLimit(2)
                    .padding(.top, 10)
            }
            CardRule(theme: theme).padding(.top, 20)
            CardLinesView(lines: content.lines(limit: 4), theme: theme).padding(.top, 14)
        }
        .padding(26)
    }

    private var horizontal: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                CardWordmark(theme: theme)
                Spacer(minLength: 12)
                accentBar
                name(size: 32).padding(.top, 14)
                designation.padding(.top, 6)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 0) {
                CardPhoto(content: content, theme: theme, size: 64)
                Spacer(minLength: 12)
                CardLinesView(lines: content.lines(limit: 4), theme: theme)
                    .frame(width: 250, alignment: .leading)
            }
        }
        .padding(24)
    }

    private var accentBar: some View {
        Rectangle().fill(theme.accent).frame(width: 36, height: 3)
    }

    private func name(size: CGFloat) -> some View {
        Text(content.displayName)
            .font(.system(size: size, weight: .regular, design: .serif))
            .foregroundStyle(theme.primary)
            .lineLimit(3)
            .minimumScaleFactor(0.55)
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
