import SwiftData
import SwiftUI

struct ConnectionsListView: View {
    enum SortOrder: String, CaseIterable, Identifiable {
        case recent = "Most recent"
        case name = "Name"

        var id: String { rawValue }
    }

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Connection.connectedAt, order: .reverse) private var connections: [Connection]
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .recent
    @State private var errorMessage: String?

    private var visibleConnections: [Connection] {
        let query = searchText.trimmed
        let filtered = query.isEmpty ? connections : connections.filter {
            $0.fullName.localizedCaseInsensitiveContains(query) || $0.designation.localizedCaseInsensitiveContains(query)
        }
        switch sortOrder {
        case .recent: return filtered
        case .name: return filtered.sorted { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if connections.isEmpty {
                    emptyState
                } else if visibleConnections.isEmpty {
                    PassEmptyState(systemImage: "magnifyingglass", title: "No matches", message: "No contacts match \u{201C}\(searchText.trimmed)\u{201D}.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    list
                }
            }
            .background(PassColors.background)
            .navigationTitle("Contacts")
            .navigationDestination(for: Connection.self) { ConnectionDetailView(connection: $0) }
            .toolbar {
                if !connections.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Picker("Sort by", selection: $sortOrder) {
                                ForEach(SortOrder.allCases) { Text($0.rawValue).tag($0) }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                    }
                }
            }
            .alert("Something went wrong", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var list: some View {
        List {
            ForEach(visibleConnections) { connection in
                NavigationLink(value: connection) {
                    ConnectionRow(connection: connection)
                }
            }
            .onDelete(perform: delete)
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText, prompt: "Search name or role")
    }

    private var emptyState: some View {
        PassEmptyState(
            systemImage: "person.2",
            title: "No connections yet",
            message: "People you scan and save appear here, with the date you met and your private notes."
        ) {
            Button("Load sample contacts", systemImage: "sparkles", action: loadSamples)
                .buttonStyle(.passSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadSamples() {
        do {
            try ConnectionRepository(context: modelContext).loadSamples()
        } catch {
            errorMessage = "Sample contacts couldn't be added."
        }
    }

    private func delete(at offsets: IndexSet) {
        let repository = ConnectionRepository(context: modelContext)
        do {
            for connection in offsets.map({ visibleConnections[$0] }) {
                try repository.delete(connection)
            }
        } catch {
            errorMessage = "That contact couldn't be deleted."
        }
    }
}

private struct ConnectionRow: View {
    let connection: Connection

    var body: some View {
        HStack(spacing: PassSpacing.s) {
            CardPhoto(content: CardContent(draft: ProfileDraft(connection: connection)), theme: .editorial, size: 44)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: PassSpacing.xs) {
                    Text(connection.fullName)
                        .font(PassTypography.headline)
                        .foregroundStyle(PassColors.textPrimary)
                    if connection.isSample { SampleBadge() }
                }
                if !connection.designation.isEmpty {
                    Text(connection.designation)
                        .font(PassTypography.callout)
                        .foregroundStyle(PassColors.textSecondary)
                        .lineLimit(1)
                }
                Text(connection.connectedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(PassTypography.metadata)
                    .foregroundStyle(PassColors.textSecondary)
            }
        }
        .padding(.vertical, PassSpacing.xxs)
        .accessibilityElement(children: .combine)
    }
}

struct SampleBadge: View {
    var body: some View {
        Text("SAMPLE")
            .font(.system(.caption2, design: .monospaced, weight: .semibold))
            .foregroundStyle(PassColors.accent)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .overlay(Capsule().strokeBorder(PassColors.accent, lineWidth: 1))
            .accessibilityLabel("Sample contact")
    }
}

#Preview {
    ConnectionsListView()
        .modelContainer(for: PassSchemaV2.models, inMemory: true)
}
