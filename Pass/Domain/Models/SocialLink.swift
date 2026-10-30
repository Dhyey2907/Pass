import Foundation
import SwiftData

extension PassSchemaV2 {
    /// A social account attached to either the user's profile or a saved connection.
    @Model
    final class SocialLink {
        @Attribute(.unique) var id: UUID
        var platformRawValue: String
        /// What the user typed: a handle or a full URL.
        var value: String
        var sortOrder: Int

        var profile: Profile?
        var connection: Connection?

        init(id: UUID = UUID(), platform: SocialPlatform, value: String, sortOrder: Int) {
            self.id = id
            self.platformRawValue = platform.rawValue
            self.value = value
            self.sortOrder = sortOrder
        }

        var platform: SocialPlatform {
            get { SocialPlatform(rawValue: platformRawValue) ?? .other }
            set { platformRawValue = newValue.rawValue }
        }

        var url: URL? { platform.profileURL(from: value) }
    }
}
