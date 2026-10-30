import Foundation
import SwiftData
import Testing
import UIKit
@testable import Pass

@MainActor
struct CardBackgroundTests {
    @Test func everyCategoryHasTenPresets() {
        for category in CardBackgroundCategory.allCases {
            #expect(CardBackgroundCatalog.presets(in: category).count == 10, "\(category)")
        }
    }

    @Test func presetIDsAreUniqueAndResolvable() {
        let ids = CardBackgroundCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count)
        #expect(!ids.contains(CardBackgroundCatalog.customPhotoID))
        for id in ids {
            #expect(CardBackgroundCatalog.preset(withID: id)?.id == id)
        }
    }

    @Test func resolvesBackgroundsSafely() throws {
        #expect(CardContent.resolveBackground(id: nil, photoData: nil) == nil)
        #expect(CardContent.resolveBackground(id: "retired-preset", photoData: nil) == nil)
        #expect(CardContent.resolveBackground(id: CardBackgroundCatalog.customPhotoID, photoData: nil) == nil)
        #expect(CardContent.resolveBackground(id: CardBackgroundCatalog.customPhotoID, photoData: Data("junk".utf8)) == nil)

        let pixel = try #require(UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { _ in }.pngData())
        guard case .photo = CardContent.resolveBackground(id: CardBackgroundCatalog.customPhotoID, photoData: pixel) else {
            Issue.record("Expected a photo background")
            return
        }
        guard case .preset(let preset) = CardContent.resolveBackground(id: "car-carbon", photoData: nil) else {
            Issue.record("Expected a preset background")
            return
        }
        #expect(preset.name == "Carbon Fiber")
    }

    @Test func repositoryDropsUploadedPhotoWhenPresetChosen() throws {
        let container = try PassPersistence.makeContainer(inMemory: true)
        let repository = ProfileRepository(context: container.mainContext)
        var draft = ProfileDraft()
        draft.fullName = "Ada"
        draft.backgroundID = CardBackgroundCatalog.customPhotoID
        draft.backgroundPhotoData = Data([1, 2, 3])
        let profile = try repository.save(draft, to: nil)
        #expect(profile.backgroundPhotoData != nil)

        draft.backgroundID = "code-terminal"
        try repository.save(draft, to: profile)
        #expect(profile.backgroundID == "code-terminal")
        #expect(profile.backgroundPhotoData == nil)
    }

    @Test func everyPresetRendersInBothOrientations() throws {
        var draft = ProfileDraft()
        draft.fullName = "Ada Lovelace"
        draft.designation = "Engineer"
        for preset in CardBackgroundCatalog.all {
            draft.backgroundID = preset.id
            for orientation in CardOrientation.allCases {
                let data = try CardExportService.renderPNG(content: CardContent(draft: draft), template: .editorial, orientation: orientation)
                #expect(data.count > 1000, "\(preset.id) \(orientation)")
            }
        }
    }
}

extension ResolvedCardBackground: @retroactive Equatable {
    public static func == (lhs: ResolvedCardBackground, rhs: ResolvedCardBackground) -> Bool {
        switch (lhs, rhs) {
        case (.preset(let a), .preset(let b)): a == b
        case (.photo(let a), .photo(let b)): a === b
        default: false
        }
    }
}
