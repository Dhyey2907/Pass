import Foundation
import SwiftData

/// Frozen copy of the V1 store shape. Never edit: SwiftData identifies existing stores by it.
enum PassSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Profile.self, SocialLink.self, ProfileProject.self, Connection.self]
    }

    @Model
    final class Profile {
        @Attribute(.unique) var id: UUID = UUID()
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now
        var fullName: String = ""
        var designation: String = ""
        var bio: String = ""
        var email: String = ""
        var phone: String = ""
        var website: String = ""
        @Attribute(.externalStorage) var photoData: Data?
        var templateRawValue: String = ""
        var orientationRawValue: String = ""
        @Relationship(deleteRule: .cascade, inverse: \PassSchemaV1.SocialLink.profile)
        var socialLinks: [PassSchemaV1.SocialLink] = []
        @Relationship(deleteRule: .cascade, inverse: \PassSchemaV1.ProfileProject.profile)
        var projects: [PassSchemaV1.ProfileProject] = []

        init() {}
    }

    @Model
    final class SocialLink {
        @Attribute(.unique) var id: UUID = UUID()
        var platformRawValue: String = ""
        var value: String = ""
        var sortOrder: Int = 0
        var profile: PassSchemaV1.Profile?
        var connection: PassSchemaV1.Connection?

        init() {}
    }

    @Model
    final class ProfileProject {
        @Attribute(.unique) var id: UUID = UUID()
        var title: String = ""
        var summary: String = ""
        var link: String = ""
        var sortOrder: Int = 0
        var profile: PassSchemaV1.Profile?
        var connection: PassSchemaV1.Connection?

        init() {}
    }

    @Model
    final class Connection {
        @Attribute(.unique) var id: UUID = UUID()
        var publicProfileURL: String = ""
        var connectedAt: Date = Date.now
        var updatedAt: Date = Date.now
        var fullName: String = ""
        var designation: String = ""
        var bio: String = ""
        var email: String = ""
        var phone: String = ""
        var website: String = ""
        @Attribute(.externalStorage) var photoData: Data?
        var notes: String = ""
        @Relationship(deleteRule: .cascade, inverse: \PassSchemaV1.SocialLink.connection)
        var socialLinks: [PassSchemaV1.SocialLink] = []
        @Relationship(deleteRule: .cascade, inverse: \PassSchemaV1.ProfileProject.connection)
        var projects: [PassSchemaV1.ProfileProject] = []

        init() {}
    }
}
