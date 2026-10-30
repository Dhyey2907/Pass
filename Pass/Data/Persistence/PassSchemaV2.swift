import Foundation
import SwiftData

/// Current schema. V2 adds card backgrounds to `Profile`.
enum PassSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Profile.self, SocialLink.self, ProfileProject.self, Connection.self]
    }
}

enum PassMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [PassSchemaV1.self, PassSchemaV2.self] }
    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: PassSchemaV1.self, toVersion: PassSchemaV2.self)]
    }
}

typealias Profile = PassSchemaV2.Profile
typealias SocialLink = PassSchemaV2.SocialLink
typealias ProfileProject = PassSchemaV2.ProfileProject
typealias Connection = PassSchemaV2.Connection
