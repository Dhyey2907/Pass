import Foundation
import SwiftData
import Testing
@testable import Pass

@MainActor
struct MigrationTests {
    @Test func v1StoreOpensAsV2WithDataIntact() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "pass.store")

        do {
            let v1Schema = Schema(versionedSchema: PassSchemaV1.self)
            let v1 = try ModelContainer(for: v1Schema, configurations: ModelConfiguration(schema: v1Schema, url: url))
            let profile = PassSchemaV1.Profile()
            profile.fullName = "Ada Lovelace"
            profile.templateRawValue = "contrast"
            let link = PassSchemaV1.SocialLink()
            link.platformRawValue = "github"
            link.value = "ada"
            profile.socialLinks = [link]
            v1.mainContext.insert(profile)
            try v1.mainContext.save()
        }

        let v2 = try PassPersistence.makeContainer(url: url)
        let migrated = try #require(try v2.mainContext.fetch(FetchDescriptor<Profile>()).first)
        #expect(migrated.fullName == "Ada Lovelace")
        #expect(migrated.template == .contrast)
        #expect(migrated.socialLinks.first?.value == "ada")
        #expect(migrated.backgroundID == nil)
        #expect(migrated.backgroundPhotoData == nil)
    }
}
