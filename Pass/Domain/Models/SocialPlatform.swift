import Foundation

enum SocialPlatform: String, CaseIterable, Codable, Identifiable {
    case linkedIn
    case github
    case instagram
    case x
    case tikTok
    case youTube
    case behance
    case dribbble
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .linkedIn: "LinkedIn"
        case .github: "GitHub"
        case .instagram: "Instagram"
        case .x: "X"
        case .tikTok: "TikTok"
        case .youTube: "YouTube"
        case .behance: "Behance"
        case .dribbble: "Dribbble"
        case .other: "Link"
        }
    }

    /// Hosts accepted when the user pastes a full URL instead of a handle.
    var knownHosts: [String] {
        switch self {
        case .linkedIn: ["linkedin.com"]
        case .github: ["github.com"]
        case .instagram: ["instagram.com"]
        case .x: ["x.com", "twitter.com"]
        case .tikTok: ["tiktok.com"]
        case .youTube: ["youtube.com", "youtu.be"]
        case .behance: ["behance.net"]
        case .dribbble: ["dribbble.com"]
        case .other: []
        }
    }

    private func profileURLString(forHandle handle: String) -> String? {
        switch self {
        case .linkedIn: "https://www.linkedin.com/in/\(handle)"
        case .github: "https://github.com/\(handle)"
        case .instagram: "https://www.instagram.com/\(handle)"
        case .x: "https://x.com/\(handle)"
        case .tikTok: "https://www.tiktok.com/@\(handle)"
        case .youTube: "https://www.youtube.com/@\(handle)"
        case .behance: "https://www.behance.net/\(handle)"
        case .dribbble: "https://dribbble.com/\(handle)"
        case .other: nil
        }
    }

    /// Resolves a handle (`@ada`, `ada`) or a pasted URL into a canonical HTTPS profile URL.
    /// Returns nil for input that cannot belong to this platform.
    func profileURL(from input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if looksLikeURL(trimmed) {
            guard let url = FieldValidator.normalizedWebURL(trimmed), let host = url.host?.lowercased() else {
                return nil
            }
            if self == .other { return url }
            let matchesHost = knownHosts.contains { host == $0 || host.hasSuffix(".\($0)") }
            return matchesHost ? url : nil
        }

        let handle = trimmed.hasPrefix("@") ? String(trimmed.dropFirst()) : trimmed
        guard SocialPlatform.isValidHandle(handle), let string = profileURLString(forHandle: handle) else {
            return nil
        }
        return URL(string: string)
    }

    private func looksLikeURL(_ value: String) -> Bool {
        value.contains("://") || value.contains("/") || (self == .other && value.contains("."))
    }

    private static let handleCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))

    static func isValidHandle(_ handle: String) -> Bool {
        !handle.isEmpty
            && handle.count <= 100
            && handle.unicodeScalars.allSatisfy { handleCharacters.contains($0) && $0.isASCII }
    }
}
