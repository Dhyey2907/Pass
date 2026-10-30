import UIKit

enum ResolvedCardBackground {
    case preset(CardBackgroundPreset)
    case photo(UIImage)
}

struct CardLine: Identifiable {
    let id: String
    let label: String
    let value: String
}

/// Render-ready snapshot of a profile. Card views read only this, so the editor draft,
/// the saved profile, and image export all render identically.
struct CardContent {
    var fullName: String
    var designation: String
    var bio: String
    var photo: UIImage?
    var contactLines: [CardLine]
    var socialLines: [CardLine]
    var background: ResolvedCardBackground?

    init(draft: ProfileDraft) {
        fullName = draft.fullName.trimmed
        designation = draft.designation.trimmed
        bio = draft.bio.trimmed
        photo = draft.photoData.flatMap(UIImage.init(data:))
        background = Self.resolveBackground(id: draft.backgroundID, photoData: draft.backgroundPhotoData)

        var contacts: [CardLine] = []
        if !draft.email.trimmed.isEmpty, FieldValidator.validateEmail(draft.email) == nil {
            contacts.append(CardLine(id: "email", label: "Email", value: draft.email.trimmed))
        }
        if !draft.phone.trimmed.isEmpty, FieldValidator.validatePhone(draft.phone) == nil {
            contacts.append(CardLine(id: "phone", label: "Phone", value: draft.phone.trimmed))
        }
        if let url = FieldValidator.normalizedWebURL(draft.website) {
            contacts.append(CardLine(id: "web", label: "Web", value: url.compactDisplayString))
        }
        contactLines = contacts

        socialLines = draft.socialLinks.compactMap { link in
            guard let url = link.platform.profileURL(from: link.value) else { return nil }
            return CardLine(id: link.id.uuidString, label: link.platform.displayName, value: url.compactDisplayString)
        }
    }

    static func resolveBackground(id: String?, photoData: Data?) -> ResolvedCardBackground? {
        guard let id else { return nil }
        if id == CardBackgroundCatalog.customPhotoID {
            return photoData.flatMap(UIImage.init(data:)).map(ResolvedCardBackground.photo)
        }
        return CardBackgroundCatalog.preset(withID: id).map(ResolvedCardBackground.preset)
    }

    var displayName: String { fullName.isEmpty ? "Your name" : fullName }

    var initials: String {
        let letters = fullName.split(separator: " ").prefix(2).compactMap(\.first)
        return letters.isEmpty ? "–" : String(letters).uppercased()
    }

    func lines(limit: Int) -> [CardLine] {
        Array((contactLines + socialLines).prefix(limit))
    }

    var accessibilitySummary: String {
        ([displayName, designation, bio] + lines(limit: 6).map { "\($0.label): \($0.value)" })
            .filter { !$0.isEmpty }
            .joined(separator: ". ")
    }
}

extension URL {
    /// `https://www.github.com/ada/` → `github.com/ada`
    var compactDisplayString: String {
        var host = self.host ?? absoluteString
        if host.hasPrefix("www.") { host.removeFirst(4) }
        let trimmedPath = path.hasSuffix("/") ? String(path.dropLast()) : path
        return host + trimmedPath
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
