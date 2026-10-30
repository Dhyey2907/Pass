import Foundation
import Testing
@testable import Pass

struct SocialPlatformTests {
    @Test func buildsProfileURLsFromHandles() {
        #expect(SocialPlatform.github.profileURL(from: "ada")?.absoluteString == "https://github.com/ada")
        #expect(SocialPlatform.instagram.profileURL(from: "@ada.l")?.absoluteString == "https://www.instagram.com/ada.l")
        #expect(SocialPlatform.linkedIn.profileURL(from: "ada-lovelace")?.absoluteString == "https://www.linkedin.com/in/ada-lovelace")
        #expect(SocialPlatform.tikTok.profileURL(from: "@ada")?.absoluteString == "https://www.tiktok.com/@ada")
    }

    @Test func acceptsPastedURLsOnMatchingHosts() {
        #expect(SocialPlatform.x.profileURL(from: "https://twitter.com/ada")?.host == "twitter.com")
        #expect(SocialPlatform.linkedIn.profileURL(from: "www.linkedin.com/in/ada")?.absoluteString == "https://www.linkedin.com/in/ada")
    }

    @Test func rejectsURLsFromOtherHosts() {
        #expect(SocialPlatform.github.profileURL(from: "https://evil.example.com/ada") == nil)
        #expect(SocialPlatform.github.profileURL(from: "https://notgithub.com/ada") == nil)
    }

    @Test(arguments: ["", "  ", "ada lovelace", "ada?x=1", "ádá"])
    func rejectsInvalidHandles(_ handle: String) {
        #expect(SocialPlatform.github.profileURL(from: handle) == nil)
    }

    @Test func otherPlatformRequiresAWebURL() {
        #expect(SocialPlatform.other.profileURL(from: "ada.dev")?.absoluteString == "https://ada.dev")
        #expect(SocialPlatform.other.profileURL(from: "ada") == nil)
    }
}
