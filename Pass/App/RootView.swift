import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isEditorPresented = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView(isEditorPresented: $isEditorPresented)
            } else {
                OnboardingView { createCard in
                    hasCompletedOnboarding = true
                    isEditorPresented = createCard
                }
            }
        }
        .tint(PassColors.accent)
        // The palette is light-only for now; Appearance settings arrive with the Settings milestone.
        .preferredColorScheme(.light)
    }
}
