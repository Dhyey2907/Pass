import PhotosUI
import SwiftData
import SwiftUI

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ProfileEditorViewModel
    @State private var isConfirmingDiscard = false
    @State private var savedCount = 0

    init(profile: Profile?) {
        _viewModel = State(initialValue: ProfileEditorViewModel(profile: profile))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ScaledCardView(content: viewModel.cardContent, template: viewModel.draft.template, orientation: viewModel.draft.orientation)
                        .frame(maxWidth: viewModel.draft.orientation == .vertical ? 220 : .infinity)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PassSpacing.s)
                        .animation(.easeInOut(duration: PassMotion.cardTransitionDuration), value: viewModel.draft.orientation)
                        .listRowBackground(Color.clear)
                } header: {
                    Text("Live preview")
                }

                EditorPhotoSection(viewModel: viewModel)
                EditorBasicsSection(viewModel: viewModel)
                EditorContactSection(viewModel: viewModel)
                EditorSocialLinksSection(viewModel: viewModel)
                EditorProjectsSection(viewModel: viewModel)

                if case .failed(let message) = viewModel.saveState {
                    Section {
                        Label(message, systemImage: "exclamationmark.circle")
                            .foregroundStyle(PassColors.destructive)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(PassColors.background)
            .navigationTitle(viewModel.isCreating ? "Create your Pass" : "Edit card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.isDirty { isConfirmingDiscard = true } else { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .disabled(viewModel.saveState == .saving || viewModel.isProcessingPhoto)
                }
            }
            .confirmationDialog("Discard your changes?", isPresented: $isConfirmingDiscard, titleVisibility: .visible) {
                Button("Discard changes", role: .destructive) { dismiss() }
                Button("Keep editing", role: .cancel) {}
            }
            .interactiveDismissDisabled(viewModel.isDirty)
            .sensoryFeedback(.success, trigger: savedCount)
        }
    }

    private func save() {
        if viewModel.save(using: ProfileRepository(context: modelContext)) {
            savedCount += 1
            dismiss()
        }
    }
}

#Preview {
    ProfileEditorView(profile: nil)
        .modelContainer(for: PassSchemaV2.models, inMemory: true)
}
