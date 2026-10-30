import Foundation

/// Editable value copy of a profile. The editor mutates this; nothing touches SwiftData until save.
struct ProfileDraft: Equatable {
    struct SocialLinkDraft: Identifiable, Equatable {
        var id = UUID()
        var platform: SocialPlatform = .linkedIn
        var value = ""
    }

    struct ProjectDraft: Identifiable, Equatable {
        var id = UUID()
        var title = ""
        var summary = ""
        var link = ""

        var isEmpty: Bool { title.trimmed.isEmpty && summary.trimmed.isEmpty && link.trimmed.isEmpty }
    }

    enum Field: Hashable {
        case fullName, designation, bio, email, phone, website
        case socialLink(UUID)
        case projectTitle(UUID)
        case projectSummary(UUID)
        case projectLink(UUID)
    }

    static let maximumSocialLinks = 8
    static let maximumProjects = 6
    static let projectTitleMaximumLength = 60
    static let projectSummaryMaximumLength = 160

    var fullName = ""
    var designation = ""
    var bio = ""
    var email = ""
    var phone = ""
    var website = ""
    var photoData: Data?
    var template: CardTemplate = .editorial
    var orientation: CardOrientation = .vertical
    var backgroundID: String?
    var backgroundPhotoData: Data?
    var socialLinks: [SocialLinkDraft] = []
    var projects: [ProjectDraft] = []

    init() {}

    init(profile: Profile) {
        fullName = profile.fullName
        designation = profile.designation
        bio = profile.bio
        email = profile.email
        phone = profile.phone
        website = profile.website
        photoData = profile.photoData
        template = profile.template
        orientation = profile.orientation
        backgroundID = profile.backgroundID
        backgroundPhotoData = profile.backgroundPhotoData
        socialLinks = profile.orderedSocialLinks.map {
            SocialLinkDraft(id: $0.id, platform: $0.platform, value: $0.value)
        }
        projects = profile.orderedProjects.map {
            ProjectDraft(id: $0.id, title: $0.title, summary: $0.summary, link: $0.link)
        }
    }

    /// Social links and projects left completely blank are ignored rather than flagged.
    func validationErrors() -> [Field: FieldValidationError] {
        var errors: [Field: FieldValidationError] = [:]
        errors[.fullName] = FieldValidator.validateRequiredText(fullName, maximumLength: FieldValidator.nameMaximumLength)
        errors[.designation] = FieldValidator.validateOptionalText(designation, maximumLength: FieldValidator.designationMaximumLength)
        errors[.bio] = FieldValidator.validateOptionalText(bio, maximumLength: FieldValidator.bioMaximumLength)
        errors[.email] = FieldValidator.validateEmail(email)
        errors[.phone] = FieldValidator.validatePhone(phone)
        errors[.website] = FieldValidator.validateWebsite(website)

        for link in socialLinks where !link.value.trimmed.isEmpty {
            if link.platform.profileURL(from: link.value) == nil {
                errors[.socialLink(link.id)] = .invalidURL
            }
        }
        for project in projects where !project.isEmpty {
            errors[.projectTitle(project.id)] = FieldValidator.validateRequiredText(project.title, maximumLength: Self.projectTitleMaximumLength)
            errors[.projectSummary(project.id)] = FieldValidator.validateOptionalText(project.summary, maximumLength: Self.projectSummaryMaximumLength)
            errors[.projectLink(project.id)] = FieldValidator.validateWebsite(project.link)
        }
        return errors
    }

    var isValid: Bool { validationErrors().isEmpty }
}
