import SwiftData
import SwiftUI

struct DesignStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let profile: Profile

    @State private var template: CardTemplate
    @State private var orientation: CardOrientation
    @State private var backgroundID: String?
    @State private var backgroundPhotoData: Data?
    @State private var errorMessage: String?

    init(profile: Profile) {
        self.profile = profile
        _template = State(initialValue: profile.template)
        _orientation = State(initialValue: profile.orientation)
        _backgroundID = State(initialValue: profile.backgroundID)
        _backgroundPhotoData = State(initialValue: profile.backgroundPhotoData)
    }

    private var previewContent: CardContent {
        var draft = ProfileDraft(profile: profile)
        draft.backgroundID = backgroundID
        draft.backgroundPhotoData = backgroundPhotoData
        return CardContent(draft: draft)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PassSpacing.l) {
                    ScaledCardView(content: previewContent, template: template, orientation: orientation)
                        .frame(maxWidth: orientation == .vertical ? 260 : .infinity)
                        .animation(reduceMotion ? nil : .easeInOut(duration: PassMotion.cardTransitionDuration), value: orientation)

                    VStack(alignment: .leading, spacing: PassSpacing.s) {
                        PassMetadataLabel("Orientation")
                        Picker("Orientation", selection: $orientation) {
                            ForEach(CardOrientation.allCases) { Text($0.displayName).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: PassSpacing.s) {
                        PassMetadataLabel("Template")
                        ForEach(CardTemplate.allCases) { option in
                            TemplateOptionRow(template: option, isSelected: option == template) {
                                template = option
                            }
                        }
                    }

                    BackgroundPicker(backgroundID: $backgroundID, photoData: $backgroundPhotoData)

                    if let errorMessage {
                        FieldErrorText(message: errorMessage)
                    }
                }
                .padding(.horizontal, PassSpacing.screenMargin)
                .padding(.vertical, PassSpacing.m)
            }
            .background(PassColors.background)
            .navigationTitle("Design")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: save).fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        profile.template = template
        profile.orientation = orientation
        profile.backgroundID = backgroundID
        profile.backgroundPhotoData = backgroundID == CardBackgroundCatalog.customPhotoID ? backgroundPhotoData : nil
        do {
            try ProfileRepository(context: modelContext).save(profile)
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = "Your design couldn't be saved. Please try again."
        }
    }
}

private struct TemplateOptionRow: View {
    let template: CardTemplate
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: PassSpacing.xxs) {
                    Text(template.displayName)
                        .font(PassTypography.headline)
                        .foregroundStyle(PassColors.textPrimary)
                    Text(template.tagline)
                        .font(PassTypography.footnote)
                        .foregroundStyle(PassColors.textSecondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? PassColors.accent : PassColors.divider)
                    .font(.title3)
                    .accessibilityHidden(true)
            }
            .padding(PassSpacing.m)
            .frame(minHeight: PassSpacing.minimumTouchTarget)
            .background(
                RoundedRectangle(cornerRadius: PassRadius.button, style: .continuous)
                    .strokeBorder(isSelected ? PassColors.accent : PassColors.divider, lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private extension CardTemplate {
    var tagline: String {
        switch self {
        case .editorial: "Serif name, warm paper, magazine feel"
        case .essential: "Clean, centred and quiet"
        case .contrast: "Bold charcoal with a striking name"
        }
    }
}
