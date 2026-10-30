import SwiftUI

/// The single card renderer used by the editor preview, My Pass, and image export.
/// Lays out at a fixed canonical size so output never depends on device or Dynamic Type.
struct CardView: View {
    let content: CardContent
    let template: CardTemplate
    let orientation: CardOrientation

    var body: some View {
        let size = CardMetrics.canonicalSize(for: orientation)
        let theme = content.background.map { CardTheme.over($0) } ?? templateTheme
        let shape = RoundedRectangle(cornerRadius: PassRadius.card, style: .continuous)
        artwork(theme: theme)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
            .background {
                if let background = content.background {
                    CardBackgroundLayer(background: background)
                } else {
                    theme.background
                }
            }
            .clipShape(shape)
            .overlay {
                if let border = theme.border {
                    shape.strokeBorder(border, lineWidth: 1)
                }
            }
            .environment(\.dynamicTypeSize, .large)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Card. \(content.accessibilitySummary)")
    }

    @ViewBuilder private func artwork(theme: CardTheme) -> some View {
        switch template {
        case .editorial: EditorialCard(content: content, orientation: orientation, theme: theme)
        case .essential: EssentialCard(content: content, orientation: orientation, theme: theme)
        case .contrast: ContrastCard(content: content, orientation: orientation, theme: theme)
        }
    }

    private var templateTheme: CardTheme {
        switch template {
        case .editorial: .editorial
        case .essential: .essential
        case .contrast: .contrast
        }
    }
}

private struct CardBackgroundLayer: View {
    let background: ResolvedCardBackground

    var body: some View {
        switch background {
        case .preset(let preset):
            CardBackgroundView(preset: preset)
        case .photo(let image):
            Color.clear
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .overlay {
                    // Scrim keeps light text legible over any photo.
                    LinearGradient(
                        colors: [Color.black.opacity(0.35), Color.black.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
    }
}

/// Scales a view laid out at `size` to fit the available width.
struct CanonicalScaledView<Content: View>: View {
    let size: CGSize
    @ViewBuilder var content: Content

    var body: some View {
        Color.clear
            .aspectRatio(size.width / size.height, contentMode: .fit)
            .overlay {
                GeometryReader { proxy in
                    content
                        .frame(width: size.width, height: size.height)
                        .scaleEffect(proxy.size.width / size.width)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
    }
}

/// Scales the canonical card to fit the available width.
struct ScaledCardView: View {
    let content: CardContent
    let template: CardTemplate
    let orientation: CardOrientation

    var body: some View {
        CanonicalScaledView(size: CardMetrics.canonicalSize(for: orientation)) {
            CardView(content: content, template: template, orientation: orientation)
        }
        .shadow(color: PassColors.charcoal.opacity(0.12), radius: 16, y: 8)
        .accessibilityElement(children: .contain)
    }
}
