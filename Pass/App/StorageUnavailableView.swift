import SwiftUI

/// Shown if the local database cannot be opened, instead of crashing on launch.
struct StorageUnavailableView: View {
    var body: some View {
        PassEmptyState(
            systemImage: "externaldrive.badge.exclamationmark",
            title: "Storage unavailable",
            message: "pass. couldn't open its local storage. Free up space on your iPhone, then reopen the app."
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PassColors.background)
        .preferredColorScheme(.light)
    }
}
