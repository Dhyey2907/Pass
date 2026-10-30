import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var isEditorPresented: Bool
    @Query(sort: \Profile.createdAt) private var profiles: [Profile]
    @State private var isDesignStudioPresented = false

    private var profile: Profile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PassSpacing.l) {
                    PassWordmark()
                    greeting
                    if let profile {
                        PassCardSection(profile: profile, onEdit: { isEditorPresented = true }, onDesign: { isDesignStudioPresented = true })
                        ProfileDetailsSection(profile: profile)
                    } else {
                        emptyCard
                    }
                }
                .padding(.horizontal, PassSpacing.screenMargin)
                .padding(.vertical, PassSpacing.m)
            }
            .background(PassColors.background)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isEditorPresented) {
                ProfileEditorView(profile: profile)
            }
            .sheet(isPresented: $isDesignStudioPresented) {
                if let profile { DesignStudioView(profile: profile) }
            }
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: PassSpacing.xxs) {
            PassMetadataLabel("Your identity")
            Text(greetingText)
                .font(PassTypography.displayLarge)
                .foregroundStyle(PassColors.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }

    private var greetingText: String {
        guard let firstName = profile?.fullName.split(separator: " ").first else { return "Make an impression." }
        return "Hello, \(firstName)."
    }

    private var emptyCard: some View {
        PassEmptyState(
            systemImage: "person.text.rectangle",
            title: "Your card lives here",
            message: "Add your name, links and projects. It only takes a minute and stays on this iPhone."
        ) {
            Button("Create your Pass") { isEditorPresented = true }
                .buttonStyle(.passPrimary)
        }
        .padding(.vertical, PassSpacing.xl)
        .overlay(
            RoundedRectangle(cornerRadius: PassRadius.card, style: .continuous)
                .strokeBorder(PassColors.divider, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
        )
    }
}

#Preview {
    HomeView(isEditorPresented: .constant(false))
        .modelContainer(for: PassSchemaV2.models, inMemory: true)
}
