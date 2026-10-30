import Foundation
import SwiftData

extension PassSchemaV2 {
    /// Work the user wants to show off: a portfolio piece, side project, or publication.
    @Model
    final class ProfileProject {
        @Attribute(.unique) var id: UUID
        var title: String
        var summary: String
        var link: String
        var sortOrder: Int

        var profile: Profile?
        var connection: Connection?

        init(id: UUID = UUID(), title: String, summary: String = "", link: String = "", sortOrder: Int) {
            self.id = id
            self.title = title
            self.summary = summary
            self.link = link
            self.sortOrder = sortOrder
        }

        var url: URL? { FieldValidator.normalizedWebURL(link) }
    }
}
