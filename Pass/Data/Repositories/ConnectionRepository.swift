import Foundation
import SwiftData

struct ConnectionRepository {
    let context: ModelContext

    func save(_ connection: Connection, now: Date = .now) throws {
        connection.updatedAt = now
        try context.save()
    }

    func delete(_ connection: Connection) throws {
        context.delete(connection)
        try context.save()
    }

    /// Adds any sample contacts that aren't already present. Safe to call repeatedly.
    func loadSamples(now: Date = .now) throws {
        let existing = Set(try context.fetch(FetchDescriptor<Connection>()).map(\.publicProfileURL))
        for sample in SampleConnections.all {
            let url = SampleConnections.urlPrefix + sample.slug
            guard !existing.contains(url) else { continue }
            let connectedAt = Calendar.current.date(byAdding: .day, value: -sample.daysAgo, to: now) ?? now
            let connection = Connection(
                publicProfileURL: url,
                fullName: sample.fullName,
                designation: sample.designation,
                bio: sample.bio,
                email: sample.email,
                website: sample.website,
                notes: sample.notes,
                now: connectedAt
            )
            connection.socialLinks = sample.socials.enumerated().map { index, social in
                SocialLink(platform: social.0, value: social.1, sortOrder: index)
            }
            connection.projects = sample.projects.enumerated().map { index, project in
                ProfileProject(title: project.title, summary: project.summary, sortOrder: index)
            }
            context.insert(connection)
        }
        try context.save()
    }

    func removeSamples() throws {
        for connection in try context.fetch(FetchDescriptor<Connection>()) where connection.isSample {
            context.delete(connection)
        }
        try context.save()
    }
}
