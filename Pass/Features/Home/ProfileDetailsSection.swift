import SwiftUI

/// Everything that doesn't fit on the card: all social links and projects.
struct ProfileDetailsSection: View {
    let profile: Profile

    var body: some View {
        VStack(alignment: .leading, spacing: PassSpacing.l) {
            let links = profile.orderedSocialLinks.compactMap { link in link.url.map { (link, $0) } }
            if !links.isEmpty {
                DetailGroup(title: "Links") {
                    ForEach(links, id: \.0.id) { link, url in
                        Link(destination: url) {
                            DetailRow(title: link.platform.displayName, subtitle: url.compactDisplayString, systemImage: "arrow.up.right")
                        }
                    }
                }
            }

            if !profile.projects.isEmpty {
                DetailGroup(title: "Projects") {
                    ForEach(profile.orderedProjects) { project in
                        if let url = project.url {
                            Link(destination: url) {
                                DetailRow(title: project.title, subtitle: project.summary, systemImage: "arrow.up.right")
                            }
                        } else {
                            DetailRow(title: project.title, subtitle: project.summary, systemImage: nil)
                        }
                    }
                }
            }
        }
    }
}

private struct DetailGroup<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: PassSpacing.s) {
            PassMetadataLabel(title)
            VStack(spacing: 0) { content }
                .overlay(
                    RoundedRectangle(cornerRadius: PassRadius.button, style: .continuous)
                        .strokeBorder(PassColors.divider, lineWidth: 1)
                )
        }
    }
}

private struct DetailRow: View {
    let title: String
    let subtitle: String
    let systemImage: String?

    var body: some View {
        HStack(spacing: PassSpacing.s) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PassTypography.headline)
                    .foregroundStyle(PassColors.textPrimary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(PassTypography.callout)
                        .foregroundStyle(PassColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer()
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(PassColors.accent)
                    .accessibilityHidden(true)
            }
        }
        .padding(PassSpacing.m)
        .frame(minHeight: PassSpacing.minimumTouchTarget)
        .contentShape(Rectangle())
    }
}
