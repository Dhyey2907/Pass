import SwiftUI

struct PassCardSection: View {
    let profile: Profile
    let onEdit: () -> Void
    let onDesign: () -> Void

    @State private var exportedImage: ExportedCardImage?
    @State private var exportFailed = false

    private var content: CardContent { CardContent(draft: ProfileDraft(profile: profile)) }

    var body: some View {
        VStack(spacing: PassSpacing.m) {
            ScaledCardView(content: content, template: profile.template, orientation: profile.orientation)
                .frame(maxWidth: profile.orientation == .vertical ? 300 : .infinity)
                .frame(maxWidth: .infinity)

            if let exportedImage {
                ShareLink(
                    item: exportedImage,
                    preview: SharePreview("\(profile.fullName)'s pass.", image: Image(systemName: "person.text.rectangle"))
                ) {
                    Label("Share Pass", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.passPrimary)
            } else if exportFailed {
                FieldErrorText(message: "Your card couldn't be prepared for sharing.")
            }

            HStack(spacing: PassSpacing.s) {
                Button("Edit card", systemImage: "pencil", action: onEdit)
                    .buttonStyle(.passSecondary)
                Button("Design", systemImage: "paintpalette", action: onDesign)
                    .buttonStyle(.passSecondary)
            }
        }
        // Re-render the shareable image whenever anything on the card changes.
        .task(id: profile.updatedAt) { renderExport() }
    }

    private func renderExport() {
        do {
            let data = try CardExportService.renderPNG(content: content, template: profile.template, orientation: profile.orientation)
            exportedImage = ExportedCardImage(data: data, fileName: "\(profile.fullName) pass.png")
            exportFailed = false
        } catch {
            exportedImage = nil
            exportFailed = true
        }
    }
}
