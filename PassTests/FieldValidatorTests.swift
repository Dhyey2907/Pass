import Foundation
import Testing
@testable import Pass

struct FieldValidatorTests {
    @Test func requiredTextRejectsBlankValues() {
        #expect(FieldValidator.validateRequiredText("", maximumLength: 80) == .required)
        #expect(FieldValidator.validateRequiredText("   \n", maximumLength: 80) == .required)
        #expect(FieldValidator.validateRequiredText("Ada Lovelace", maximumLength: 80) == nil)
    }

    @Test func textLengthLimitIgnoresSurroundingWhitespace() {
        #expect(FieldValidator.validateRequiredText("  abc  ", maximumLength: 3) == nil)
        #expect(FieldValidator.validateRequiredText("abcd", maximumLength: 3) == .tooLong(maximum: 3))
    }

    @Test(arguments: ["ada@example.com", "a.b+tag@sub.example.co.uk", "  ada@example.io "])
    func acceptsValidEmails(_ email: String) {
        #expect(FieldValidator.validateEmail(email) == nil)
    }

    @Test(arguments: ["ada", "ada@", "ada@example", "ada @example.com", "@example.com", "ada@example.c"])
    func rejectsInvalidEmails(_ email: String) {
        #expect(FieldValidator.validateEmail(email) == .invalidEmail)
    }

    @Test func emptyOptionalFieldsAreValid() {
        #expect(FieldValidator.validateEmail("") == nil)
        #expect(FieldValidator.validatePhone("  ") == nil)
        #expect(FieldValidator.validateWebsite("") == nil)
    }

    @Test(arguments: ["+1 (555) 123-4567", "020 7946 0958", "+91.98765.43210", "5551234"])
    func acceptsValidPhones(_ phone: String) {
        #expect(FieldValidator.validatePhone(phone) == nil)
    }

    @Test(arguments: ["123", "call me", "+1 555 123 4567 8901 234", "555-CALL-NOW"])
    func rejectsInvalidPhones(_ phone: String) {
        #expect(FieldValidator.validatePhone(phone) == .invalidPhone)
    }

    @Test func normalizesBareDomainsToHTTPS() {
        #expect(FieldValidator.normalizedWebURL("example.com")?.absoluteString == "https://example.com")
        #expect(FieldValidator.normalizedWebURL("http://example.com/a")?.absoluteString == "http://example.com/a")
    }

    @Test(arguments: ["javascript:alert(1)", "ftp://example.com", "localhost", "exa mple.com", "https://.com", "tel:5551234"])
    func rejectsUnsafeOrMalformedURLs(_ value: String) {
        #expect(FieldValidator.normalizedWebURL(value) == nil)
        #expect(FieldValidator.validateWebsite(value) == .invalidURL)
    }
}
