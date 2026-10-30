import Foundation
import SwiftData

extension PassSchemaV2 {
    /// The user's own card. Local-only: publication state is tracked separately once publishing exists.
    @Model
    final class Profile {
        @Attribute(.unique) var id: UUID
        var createdAt: Date
        var updatedAt: Date

        var fullName: String
        var designation: String
        var bio: String
        var email: String
        var phone: String
        var website: String
        @Attribute(.externalStorage) var photoData: Data?

        var templateRawValue: String
        var orientationRawValue: String

        /// A `CardBackgroundCatalog` preset ID, `CardBackgroundCatalog.customPhotoID`, or nil for the template's own.
        var backgroundID: String? = nil
        @Attribute(.externalStorage) var backgroundPhotoData: Data? = nil

        @Relationship(deleteRule: .cascade, inverse: \SocialLink.profile)
        var socialLinks: [SocialLink] = []

        @Relationship(deleteRule: .cascade, inverse: \ProfileProject.profile)
        var projects: [ProfileProject] = []

        init(
            id: UUID = UUID(),
            fullName: String,
            designation: String = "",
            bio: String = "",
            email: String = "",
            phone: String = "",
            website: String = "",
            template: CardTemplate = .editorial,
            orientation: CardOrientation = .vertical,
            now: Date = .now
        ) {
            self.id = id
            self.createdAt = now
            self.updatedAt = now
            self.fullName = fullName
            self.designation = designation
            self.bio = bio
            self.email = email
            self.phone = phone
            self.website = website
            self.templateRawValue = template.rawValue
            self.orientationRawValue = orientation.rawValue
        }

        var template: CardTemplate {
            get { CardTemplate(rawValue: templateRawValue) ?? .editorial }
            set { templateRawValue = newValue.rawValue }
        }

        var orientation: CardOrientation {
            get { CardOrientation(rawValue: orientationRawValue) ?? .vertical }
            set { orientationRawValue = newValue.rawValue }
        }

        var orderedSocialLinks: [SocialLink] {
            socialLinks.sorted { $0.sortOrder < $1.sortOrder }
        }

        var orderedProjects: [ProfileProject] {
            projects.sorted { $0.sortOrder < $1.sortOrder }
        }
    }
}
