import SwiftData
import SwiftUI

struct ConnectionsListView: View {
    @Query(sort: \Connection.connectedAt, order: .reverse) private var connections: [Connection]

    var body: some View {
        NavigationStack {
            Group {
                if connections.isEmpty {
                    PassEmptyState(
                        systemImage: "person.2",
                        title: "No connections yet",
                        message: "People you scan and save appear here, with the date you met and your private notes."
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(connections) { connection in
                        ConnectionRow(connection: connection)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(PassColors.background)
            .navigationTitle("Contacts")
        }
    }
}

private struct ConnectionRow: View {
    let connection: Connection

    var body: some View {
        VStack(alignment: .leading, spacing: PassSpacing.xxs) {
            Text(connection.fullName)
                .font(PassTypography.headline)
                .foregroundStyle(PassColors.textPrimary)
            if !connection.designation.isEmpty {
                Text(connection.designation)
                    .font(PassTypography.callout)
                    .foregroundStyle(PassColors.textSecondary)
            }
        }
        .padding(.vertical, PassSpacing.xxs)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ConnectionsListView()
        .modelContainer(for: PassSchemaV2.models, inMemory: true)
}
