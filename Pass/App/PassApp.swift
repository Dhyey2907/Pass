import SwiftData
import SwiftUI

@main
struct PassApp: App {
    private let container: Result<ModelContainer, Error>

    init() {
        container = Result { try PassPersistence.makeContainer() }
    }

    var body: some Scene {
        WindowGroup {
            switch container {
            case .success(let modelContainer):
                RootView()
                    .modelContainer(modelContainer)
            case .failure:
                StorageUnavailableView()
            }
        }
    }
}
