import Foundation
import SwiftData

enum ProfileRepositoryError: Error {
    case invalidDraft
}

struct ProfileRepository {
    let context: ModelContext

    /// The first card the user created. Multiple cards are a later feature.
    func primaryProfile() throws -> Profile? {
        var descriptor = FetchDescriptor<Profile>(sortBy: [SortDescriptor(\.createdAt)])
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    @discardableResult
    func createProfile(fullName: String, now: Date = .now) throws -> Profile {
        let profile = Profile(fullName: fullName.trimmed, now: now)
        context.insert(profile)
        try context.save()
        return profile
    }

    func save(_ profile: Profile, now: Date = .now) throws {
        profile.updatedAt = now
        try context.save()
    }

    /// Writes a validated draft to `existing`, or creates a new profile. Rolls back on failure.
    @discardableResult
    func save(_ draft: ProfileDraft, to existing: Profile?, now: Date = .now) throws -> Profile {
        guard draft.isValid else { throw ProfileRepositoryError.invalidDraft }

        let profile: Profile
        if let existing {
            profile = existing
        } else {
            profile = Profile(fullName: "", now: now)
            context.insert(profile)
        }

        profile.fullName = draft.fullName.trimmed
        profile.designation = draft.designation.trimmed
        profile.bio = draft.bio.trimmed
        profile.email = draft.email.trimmed
        profile.phone = draft.phone.trimmed
        profile.website = draft.website.trimmed
        profile.photoData = draft.photoData
        profile.template = draft.template
        profile.orientation = draft.orientation
        profile.backgroundID = draft.backgroundID
        // Keep an uploaded image only while it is the selected background.
        profile.backgroundPhotoData = draft.backgroundID == CardBackgroundCatalog.customPhotoID ? draft.backgroundPhotoData : nil
        syncSocialLinks(of: profile, with: draft.socialLinks.filter { !$0.value.trimmed.isEmpty })
        syncProjects(of: profile, with: draft.projects.filter { !$0.isEmpty })
        profile.updatedAt = now

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
        return profile
    }

    /// Removes every local profile and saved connection. Does not touch any hosted public profile.
    func deleteAllLocalData() throws {
        // Delete row by row so cascade rules remove attached links and projects.
        for profile in try context.fetch(FetchDescriptor<Profile>()) {
            context.delete(profile)
        }
        for connection in try context.fetch(FetchDescriptor<Connection>()) {
            context.delete(connection)
        }
        try context.save()
    }

    private func syncSocialLinks(of profile: Profile, with drafts: [ProfileDraft.SocialLinkDraft]) {
        let existing = Dictionary(uniqueKeysWithValues: profile.socialLinks.map { ($0.id, $0) })
        let keptIDs = Set(drafts.map(\.id))
        for link in profile.socialLinks where !keptIDs.contains(link.id) {
            context.delete(link)
        }
        profile.socialLinks = drafts.enumerated().map { index, draft in
            let link = existing[draft.id] ?? SocialLink(id: draft.id, platform: draft.platform, value: "", sortOrder: index)
            link.platform = draft.platform
            link.value = draft.value.trimmed
            link.sortOrder = index
            return link
        }
    }

    private func syncProjects(of profile: Profile, with drafts: [ProfileDraft.ProjectDraft]) {
        let existing = Dictionary(uniqueKeysWithValues: profile.projects.map { ($0.id, $0) })
        let keptIDs = Set(drafts.map(\.id))
        for project in profile.projects where !keptIDs.contains(project.id) {
            context.delete(project)
        }
        profile.projects = drafts.enumerated().map { index, draft in
            let project = existing[draft.id] ?? ProfileProject(id: draft.id, title: "", sortOrder: index)
            project.title = draft.title.trimmed
            project.summary = draft.summary.trimmed
            project.link = draft.link.trimmed
            project.sortOrder = index
            return project
        }
    }
}
