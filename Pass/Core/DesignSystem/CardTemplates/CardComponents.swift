import SwiftUI

struct CardPhoto: View {
    let content: CardContent
    let theme: CardTheme
    let size: CGFloat
    var cornerRadius: CGFloat? = nil

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius ?? size / 2, style: .continuous)
        Group {
            if let photo = content.photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    theme.accent.opacity(0.18)
                    Text(content.initials)
                        .font(.system(size: size * 0.34, weight: .regular, design: .serif))
                        .foregroundStyle(theme.primary)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(shape)
    }
}

struct CardWordmark: View {
    let theme: CardTheme

    var body: some View {
        (Text("pass").foregroundStyle(theme.primary) + Text(".").foregroundStyle(theme.accent))
            .font(.system(size: 15, weight: .medium, design: .serif))
    }
}

struct CardMetaText: View {
    let text: String
    let theme: CardTheme

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 8.5, weight: .medium, design: .monospaced))
            .tracking(1)
            .foregroundStyle(theme.secondary)
    }
}

struct CardLinesView: View {
    let lines: [CardLine]
    let theme: CardTheme
    var monospaced = true

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ForEach(lines) { line in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    CardMetaText(text: line.label, theme: theme)
                        .frame(width: 62, alignment: .leading)
                    Text(line.value)
                        .font(.system(size: 11.5, design: monospaced ? .monospaced : .default))
                        .foregroundStyle(theme.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}

struct CardRule: View {
    let theme: CardTheme

    var body: some View {
        Rectangle().fill(theme.rule).frame(height: 1)
    }
}
