import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var connections: [Connection]
    @State private var isConfirmingDeletion = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Delete all local data", role: .destructive) {
                        isConfirmingDeletion = true
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Removes your cards and saved connections from this iPhone. Any public profile you publish must be unpublished separately.")
                }

                Section {
                    if connections.contains(where: { $0.isSample }) {
                        Button("Remove sample contacts", role: .destructive) {
                            perform { try ConnectionRepository(context: modelContext).removeSamples() }
                        }
                    } else {
                        Button("Add sample contacts") {
                            perform { try ConnectionRepository(context: modelContext).loadSamples() }
                        }
                    }
                } header: {
                    Text("Showcase")
                } footer: {
                    Text("Fictional contacts for demos, marked “Sample”. They never mix with your real connections.")
                }

                Section("About") {
                    LabeledContent("Version", value: Bundle.main.appVersionDescription)
                }
            }
            .scrollContentBackground(.hidden)
            .background(PassColors.background)
            .navigationTitle("Settings")
            .confirmationDialog(
                "Delete all local data?",
                isPresented: $isConfirmingDeletion,
                titleVisibility: .visible
            ) {
                Button("Delete everything", role: .destructive, action: deleteAllLocalData)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func deleteAllLocalData() {
        perform { try ProfileRepository(context: modelContext).deleteAllLocalData() }
    }

    private func perform(_ action: () throws -> Void) {
        do {
            try action()
        } catch {
            errorMessage = "Your data is unchanged. Please try again."
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: PassSchemaV2.models, inMemory: true)
}
