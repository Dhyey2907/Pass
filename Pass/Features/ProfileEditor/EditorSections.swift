import PhotosUI
import SwiftUI

struct EditorPhotoSection: View {
    @Bindable var viewModel: ProfileEditorViewModel

    var body: some View {
        Section {
            HStack(spacing: PassSpacing.m) {
                CardPhoto(content: viewModel.cardContent, theme: .editorial, size: 56)
                    .overlay {
                        if viewModel.isProcessingPhoto { ProgressView() }
                    }
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: PassSpacing.xs) {
                    PhotosPicker(selection: $viewModel.photoSelection, matching: .images, photoLibrary: .shared()) {
                        Text(viewModel.draft.photoData == nil ? "Add photo" : "Change photo")
                    }
                    if viewModel.draft.photoData != nil {
                        Button("Remove photo", role: .destructive, action: viewModel.removePhoto)
                    }
                }
            }
            if let message = viewModel.photoErrorMessage {
                FieldErrorText(message: message)
            }
        } header: {
            Text("Photo")
        } footer: {
            Text("Optional. Only the photo you pick is shared with pass.")
        }
    }
}

struct EditorBasicsSection: View {
    @Bindable var viewModel: ProfileEditorViewModel

    var body: some View {
        Section {
            ValidatedField("Full name", text: $viewModel.draft.fullName, error: viewModel.errorMessage(for: .fullName))
                .textContentType(.name)
                .textInputAutocapitalization(.words)
            ValidatedField("Role or title", text: $viewModel.draft.designation, error: viewModel.errorMessage(for: .designation))
                .textContentType(.jobTitle)
            VStack(alignment: .leading, spacing: PassSpacing.xxs) {
                TextField("Short bio", text: $viewModel.draft.bio, axis: .vertical)
                    .lineLimit(2...5)
                HStack {
                    if let error = viewModel.errorMessage(for: .bio) { FieldErrorText(message: error) }
                    Spacer()
                    Text("\(viewModel.draft.bio.trimmed.count)/\(FieldValidator.bioMaximumLength)")
                        .font(PassTypography.metadata)
                        .foregroundStyle(PassColors.textSecondary)
                        .accessibilityLabel("\(viewModel.draft.bio.trimmed.count) of \(FieldValidator.bioMaximumLength) characters")
                }
            }
        } header: {
            Text("About you")
        } footer: {
            Text("Full name is required. Everything else is optional.")
        }
    }
}

struct EditorContactSection: View {
    @Bindable var viewModel: ProfileEditorViewModel

    var body: some View {
        Section("Contact · optional") {
            ValidatedField("Email", text: $viewModel.draft.email, error: viewModel.errorMessage(for: .email))
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            ValidatedField("Phone", text: $viewModel.draft.phone, error: viewModel.errorMessage(for: .phone))
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
            ValidatedField("Website", text: $viewModel.draft.website, error: viewModel.errorMessage(for: .website))
                .textContentType(.URL)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }
}

struct EditorSocialLinksSection: View {
    @Bindable var viewModel: ProfileEditorViewModel

    var body: some View {
        Section {
            ForEach($viewModel.draft.socialLinks) { $link in
                VStack(alignment: .leading, spacing: PassSpacing.xs) {
                    Picker("Platform", selection: $link.platform) {
                        ForEach(SocialPlatform.allCases) { Text($0.displayName).tag($0) }
                    }
                    ValidatedField(
                        link.platform == .other ? "https://…" : "@handle or profile link",
                        text: $link.value,
                        error: viewModel.errorMessage(for: .socialLink(link.id))
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                }
            }
            .onDelete { viewModel.draft.socialLinks.remove(atOffsets: $0) }
            .onMove { viewModel.draft.socialLinks.move(fromOffsets: $0, toOffset: $1) }

            if viewModel.draft.socialLinks.count < ProfileDraft.maximumSocialLinks {
                Button("Add social link", systemImage: "plus.circle", action: viewModel.addSocialLink)
            }
        } header: {
            Text("Social links · optional")
        } footer: {
            Text("Swipe left to remove. The first links appear on your card; all of them appear on My Pass.")
        }
    }
}

struct EditorProjectsSection: View {
    @Bindable var viewModel: ProfileEditorViewModel

    var body: some View {
        Section {
            ForEach($viewModel.draft.projects) { $project in
                VStack(alignment: .leading, spacing: PassSpacing.xs) {
                    ValidatedField("Project title", text: $project.title, error: viewModel.errorMessage(for: .projectTitle(project.id)))
                    ValidatedField("What it is, in a sentence", text: $project.summary, error: viewModel.errorMessage(for: .projectSummary(project.id)))
                    ValidatedField("Link", text: $project.link, error: viewModel.errorMessage(for: .projectLink(project.id)))
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.vertical, PassSpacing.xxs)
            }
            .onDelete { viewModel.draft.projects.remove(atOffsets: $0) }
            .onMove { viewModel.draft.projects.move(fromOffsets: $0, toOffset: $1) }

            if viewModel.draft.projects.count < ProfileDraft.maximumProjects {
                Button("Add project", systemImage: "plus.circle", action: viewModel.addProject)
            }
        } header: {
            Text("Projects · optional")
        } footer: {
            Text("Show off your work: apps, research, designs, side projects. Swipe left to remove.")
        }
    }
}
