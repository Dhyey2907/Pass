import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isConfirmingDeletion = false
    @State private var deletionError: String?

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
                "Couldn't delete data",
                isPresented: Binding(get: { deletionError != nil }, set: { if !$0 { deletionError = nil } })
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deletionError ?? "")
            }
        }
    }

    private func deleteAllLocalData() {
        do {
            try ProfileRepository(context: modelContext).deleteAllLocalData()
        } catch {
            deletionError = "Your data is unchanged. Please try again."
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: PassSchemaV2.models, inMemory: true)
}
