import SwiftData
import SwiftUI

struct ConnectionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var connection: Connection
    @State private var isConfirmingDelete = false
    @State private var errorMessage: String?

    private var sample: SampleConnections.Sample? { SampleConnections.sample(for: connection) }

    private var cardContent: CardContent {
        var draft = ProfileDraft(connection: connection)
        draft.backgroundID = sample?.backgroundID
        return CardContent(draft: draft)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PassSpacing.l) {
                let orientation = sample?.orientation ?? .vertical
                ScaledCardView(content: cardContent, template: sample?.template ?? .editorial, orientation: orientation)
                    .frame(maxWidth: orientation == .vertical ? 280 : .infinity)
                    .frame(maxWidth: .infinity)

                HStack(spacing: PassSpacing.xs) {
                    PassMetadataLabel("Connected \(connection.connectedAt.formatted(date: .abbreviated, time: .omitted))")
                    if connection.isSample { SampleBadge() }
                }

                if connection.isSample {
                    Text("This is a fictional sample contact for demos. Its links are disabled.")
                        .font(PassTypography.footnote)
                        .foregroundStyle(PassColors.textSecondary)
                }

                linksSection
                projectsSection
                notesSection

                Button("Delete contact", role: .destructive) { isConfirmingDelete = true }
                    .buttonStyle(.passSecondary)
            }
            .padding(.horizontal, PassSpacing.screenMargin)
            .padding(.vertical, PassSpacing.m)
        }
        .background(PassColors.background)
        .navigationTitle(connection.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: saveNotes)
        .confirmationDialog("Delete \(connection.fullName)?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: delete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the contact and your notes from this iPhone.")
        }
        .alert("Something went wrong", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @ViewBuilder private var linksSection: some View {
        let links = connection.orderedSocialLinks.compactMap { link in link.url.map { (link, $0) } }
        if !links.isEmpty {
            DetailSection(title: "Links") {
                ForEach(links, id: \.0.id) { link, url in
                    DetailLinkRow(title: link.platform.displayName, subtitle: url.compactDisplayString, url: connection.isSample ? nil : url)
                }
            }
        }
    }

    @ViewBuilder private var projectsSection: some View {
        if !connection.projects.isEmpty {
            DetailSection(title: "Projects") {
                ForEach(connection.orderedProjects) { project in
                    DetailLinkRow(title: project.title, subtitle: project.summary, url: connection.isSample ? nil : project.url)
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: PassSpacing.s) {
            PassMetadataLabel("Private notes")
            TextField("Where you met, what to follow up on…", text: $connection.notes, axis: .vertical)
                .lineLimit(3...8)
                .padding(PassSpacing.s)
                .overlay(
                    RoundedRectangle(cornerRadius: PassRadius.control, style: .continuous)
                        .strokeBorder(PassColors.divider, lineWidth: 1)
                )
            Text("Notes stay on this iPhone and are never shared.")
                .font(PassTypography.footnote)
                .foregroundStyle(PassColors.textSecondary)
        }
    }

    private func saveNotes() {
        guard !connection.isDeleted, connection.hasChanges else { return }
        try? ConnectionRepository(context: modelContext).save(connection)
    }

    private func delete() {
        do {
            try ConnectionRepository(context: modelContext).delete(connection)
            dismiss()
        } catch {
            errorMessage = "That contact couldn't be deleted."
        }
    }
}

private struct DetailSection<Content: View>: View {
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

private struct DetailLinkRow: View {
    let title: String
    let subtitle: String
    let url: URL?

    var body: some View {
        if let url {
            Link(destination: url) { row(showsArrow: true) }
        } else {
            row(showsArrow: false)
        }
    }

    private func row(showsArrow: Bool) -> some View {
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
            if showsArrow {
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(PassColors.accent)
                    .accessibilityHidden(true)
            }
        }
        .padding(PassSpacing.m)
        .frame(minHeight: PassSpacing.minimumTouchTarget)
        .contentShape(Rectangle())
    }
}
