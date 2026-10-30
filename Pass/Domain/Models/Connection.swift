import Foundation
import SwiftData

extension PassSchemaV2 {
    /// Someone else's pass, saved locally after the user scanned and confirmed it.
    @Model
    final class Connection {
        @Attribute(.unique) var id: UUID
        /// Canonical HTTPS URL of the public profile this snapshot came from.
        var publicProfileURL: String
        var connectedAt: Date
        var updatedAt: Date

        var fullName: String
        var designation: String
        var bio: String
        var email: String
        var phone: String
        var website: String
        @Attribute(.externalStorage) var photoData: Data?

        /// Private to this device; never published.
        var notes: String

        @Relationship(deleteRule: .cascade, inverse: \SocialLink.connection)
        var socialLinks: [SocialLink] = []

        @Relationship(deleteRule: .cascade, inverse: \ProfileProject.connection)
        var projects: [ProfileProject] = []

        init(
            id: UUID = UUID(),
            publicProfileURL: String,
            fullName: String,
            designation: String = "",
            bio: String = "",
            email: String = "",
            phone: String = "",
            website: String = "",
            notes: String = "",
            now: Date = .now
        ) {
            self.id = id
            self.publicProfileURL = publicProfileURL
            self.connectedAt = now
            self.updatedAt = now
            self.fullName = fullName
            self.designation = designation
            self.bio = bio
            self.email = email
            self.phone = phone
            self.website = website
            self.notes = notes
        }

        var orderedSocialLinks: [SocialLink] {
            socialLinks.sorted { $0.sortOrder < $1.sortOrder }
        }

        var orderedProjects: [ProfileProject] {
            projects.sorted { $0.sortOrder < $1.sortOrder }
        }
    }
}
