import Foundation

enum FieldValidationError: Error, Equatable {
    case required
    case tooLong(maximum: Int)
    case invalidEmail
    case invalidPhone
    case invalidURL

    var message: String {
        switch self {
        case .required: "Required"
        case .tooLong(let maximum): "Keep this under \(maximum) characters"
        case .invalidEmail: "Enter an email like name@example.com"
        case .invalidPhone: "Enter a phone number with 7 to 15 digits"
        case .invalidURL: "Enter a web address like example.com"
        }
    }
}

/// Deliberately permissive checks: catch obvious typos without rejecting real-world values.
enum FieldValidator {
    static let nameMaximumLength = 80
    static let designationMaximumLength = 80
    static let bioMaximumLength = 280

    static func validateRequiredText(_ value: String, maximumLength: Int) -> FieldValidationError? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .required }
        return validateOptionalText(trimmed, maximumLength: maximumLength)
    }

    static func validateOptionalText(_ value: String, maximumLength: Int) -> FieldValidationError? {
        value.trimmingCharacters(in: .whitespacesAndNewlines).count > maximumLength
            ? .tooLong(maximum: maximumLength)
            : nil
    }

    /// Empty optional fields are valid; only filled-in values are checked.
    static func validateEmail(_ value: String) -> FieldValidationError? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@.]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) == nil ? .invalidEmail : nil
    }

    static func validatePhone(_ value: String) -> FieldValidationError? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let allowed = CharacterSet(charactersIn: "0123456789+-(). ")
        guard trimmed.unicodeScalars.allSatisfy(allowed.contains) else { return .invalidPhone }
        let digitCount = trimmed.filter(\.isASCIIDigit).count
        return (7...15).contains(digitCount) ? nil : .invalidPhone
    }

    static func validateWebsite(_ value: String) -> FieldValidationError? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return normalizedWebURL(trimmed) == nil ? .invalidURL : nil
    }

    /// Adds `https://` when no scheme is given and accepts only http(s) URLs with a dotted host.
    static func normalizedWebURL(_ value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains(" ") else { return nil }
        let candidate = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard
            let components = URLComponents(string: candidate),
            let scheme = components.scheme?.lowercased(),
            scheme == "https" || scheme == "http",
            let host = components.host,
            host.contains("."),
            !host.hasPrefix("."),
            !host.hasSuffix(".")
        else { return nil }
        return components.url
    }
}

private extension Character {
    var isASCIIDigit: Bool { isASCII && isNumber }
}
