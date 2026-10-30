import Foundation
import SwiftData
import Testing
@testable import Pass

@MainActor
struct ProfileRepositoryTests {
    private let container: ModelContainer
    private let repository: ProfileRepository

    init() throws {
        container = try PassPersistence.makeContainer(inMemory: true)
        repository = ProfileRepository(context: container.mainContext)
    }

    @Test func hasNoProfileInitially() throws {
        #expect(try repository.primaryProfile() == nil)
    }

    @Test func createsProfileWithTrimmedNameAndDefaults() throws {
        let profile = try repository.createProfile(fullName: "  Ada Lovelace ")
        #expect(profile.fullName == "Ada Lovelace")
        #expect(profile.template == .editorial)
        #expect(profile.orientation == .vertical)
        #expect(try repository.primaryProfile()?.id == profile.id)
    }

    @Test func primaryProfileIsTheOldest() throws {
        let first = try repository.createProfile(fullName: "First", now: Date(timeIntervalSince1970: 100))
        try repository.createProfile(fullName: "Second", now: Date(timeIntervalSince1970: 200))
        #expect(try repository.primaryProfile()?.id == first.id)
    }

    @Test func saveUpdatesTimestampAndPersistsDesignChoices() throws {
        let profile = try repository.createProfile(fullName: "Ada", now: Date(timeIntervalSince1970: 0))
        profile.template = .contrast
        profile.orientation = .horizontal
        try repository.save(profile, now: Date(timeIntervalSince1970: 50))

        let reloaded = try #require(try repository.primaryProfile())
        #expect(reloaded.templateRawValue == "contrast")
        #expect(reloaded.orientation == .horizontal)
        #expect(reloaded.updatedAt == Date(timeIntervalSince1970: 50))
    }

    @Test func unknownStoredRawValuesFallBackSafely() throws {
        let profile = try repository.createProfile(fullName: "Ada")
        profile.templateRawValue = "retired-template"
        profile.orientationRawValue = "diagonal"
        #expect(profile.template == .editorial)
        #expect(profile.orientation == .vertical)
    }

    @Test func orderedChildrenFollowSortOrder() throws {
        let profile = try repository.createProfile(fullName: "Ada")
        profile.socialLinks = [
            SocialLink(platform: .x, value: "ada", sortOrder: 1),
            SocialLink(platform: .github, value: "ada", sortOrder: 0),
        ]
        profile.projects = [
            ProfileProject(title: "Engine", sortOrder: 1),
            ProfileProject(title: "Notes", sortOrder: 0),
        ]
        try repository.save(profile)
        #expect(profile.orderedSocialLinks.map(\.platform) == [.github, .x])
        #expect(profile.orderedProjects.map(\.title) == ["Notes", "Engine"])
    }

    @Test func deleteAllLocalDataCascadesToChildren() throws {
        let context = container.mainContext
        let profile = try repository.createProfile(fullName: "Ada")
        profile.socialLinks = [SocialLink(platform: .github, value: "ada", sortOrder: 0)]
        profile.projects = [ProfileProject(title: "Engine", sortOrder: 0)]
        let connection = Connection(publicProfileURL: "https://example.com/p/abc", fullName: "Grace")
        connection.socialLinks = [SocialLink(platform: .linkedIn, value: "grace", sortOrder: 0)]
        context.insert(connection)
        try context.save()

        try repository.deleteAllLocalData()

        #expect(try context.fetchCount(FetchDescriptor<Profile>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Connection>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<SocialLink>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<ProfileProject>()) == 0)
    }
}
