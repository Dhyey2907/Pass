import Foundation
import SwiftData
import Testing
@testable import Pass

@MainActor
struct ProfileDraftTests {
    private let container: ModelContainer
    private let repository: ProfileRepository

    init() throws {
        container = try PassPersistence.makeContainer(inMemory: true)
        repository = ProfileRepository(context: container.mainContext)
    }

    private func validDraft() -> ProfileDraft {
        var draft = ProfileDraft()
        draft.fullName = "Ada Lovelace"
        return draft
    }

    @Test func emptyDraftRequiresName() {
        #expect(ProfileDraft().validationErrors()[.fullName] == .required)
        #expect(validDraft().isValid)
    }

    @Test func blankSocialLinksAndProjectsAreIgnored() {
        var draft = validDraft()
        draft.socialLinks = [.init(platform: .github, value: "  ")]
        draft.projects = [.init()]
        #expect(draft.isValid)
    }

    @Test func flagsInvalidSocialLinkAndUntitledProject() {
        var draft = validDraft()
        let link = ProfileDraft.SocialLinkDraft(platform: .github, value: "https://evil.example.com/ada")
        let project = ProfileDraft.ProjectDraft(summary: "A thing I built")
        draft.socialLinks = [link]
        draft.projects = [project]
        let errors = draft.validationErrors()
        #expect(errors[.socialLink(link.id)] == .invalidURL)
        #expect(errors[.projectTitle(project.id)] == .required)
    }

    @Test func repositoryRefusesInvalidDraft() {
        #expect(throws: ProfileRepositoryError.self) {
            try repository.save(ProfileDraft(), to: nil)
        }
        #expect((try? repository.primaryProfile()) == nil)
    }

    @Test func savesNewProfileAndRoundTripsThroughDraft() throws {
        var draft = validDraft()
        draft.designation = " Engineer "
        draft.email = "ada@example.com"
        draft.template = .contrast
        draft.orientation = .horizontal
        draft.socialLinks = [.init(platform: .github, value: "ada"), .init(platform: .x, value: "")]
        draft.projects = [.init(title: "Analytical Engine", summary: "Notes", link: "ada.dev")]

        let profile = try repository.save(draft, to: nil)

        #expect(profile.designation == "Engineer")
        #expect(profile.socialLinks.count == 1)
        #expect(profile.projects.first?.title == "Analytical Engine")
        let reloaded = ProfileDraft(profile: profile)
        #expect(reloaded.template == .contrast)
        #expect(reloaded.orientation == .horizontal)
        #expect(reloaded.socialLinks.map(\.value) == ["ada"])
    }

    @Test func updatingRemovesDroppedChildrenAndReorders() throws {
        var draft = validDraft()
        let first = ProfileDraft.SocialLinkDraft(platform: .github, value: "ada")
        let second = ProfileDraft.SocialLinkDraft(platform: .linkedIn, value: "ada")
        draft.socialLinks = [first, second]
        draft.projects = [.init(title: "One"), .init(title: "Two")]
        let profile = try repository.save(draft, to: nil)

        var edited = ProfileDraft(profile: profile)
        edited.socialLinks = [second]
        edited.projects.removeFirst()
        try repository.save(edited, to: profile)

        let context = container.mainContext
        #expect(try context.fetchCount(FetchDescriptor<SocialLink>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<ProfileProject>()) == 1)
        #expect(profile.orderedSocialLinks.first?.id == second.id)
        #expect(profile.orderedSocialLinks.first?.sortOrder == 0)
        #expect(profile.orderedProjects.map(\.title) == ["Two"])
    }

    @Test func cardContentShowsOnlyValidLinesInOrder() {
        var draft = validDraft()
        draft.email = "not-an-email"
        draft.phone = "+1 555 123 4567"
        draft.website = "https://www.ada.dev/"
        draft.socialLinks = [.init(platform: .github, value: "ada"), .init(platform: .x, value: "bad handle")]
        let content = CardContent(draft: draft)
        #expect(content.lines(limit: 10).map(\.value) == ["+1 555 123 4567", "ada.dev", "github.com/ada"])
        #expect(content.initials == "AL")
    }

    @Test func cardRendersToPNGForEveryTemplateAndOrientation() throws {
        let content = CardContent(draft: validDraft())
        for template in CardTemplate.allCases {
            for orientation in CardOrientation.allCases {
                let data = try CardExportService.renderPNG(content: content, template: template, orientation: orientation)
                #expect(data.count > 1000)
            }
        }
    }
}
