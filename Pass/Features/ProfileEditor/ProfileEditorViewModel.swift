import Observation
import PhotosUI
import SwiftUI

@Observable
final class ProfileEditorViewModel {
    enum SaveState: Equatable {
        case idle
        case saving
        case failed(String)
    }

    var draft: ProfileDraft
    var photoSelection: PhotosPickerItem? {
        didSet { if let photoSelection { loadPhoto(photoSelection) } }
    }
    private(set) var hasAttemptedSave = false
    private(set) var saveState: SaveState = .idle
    private(set) var isProcessingPhoto = false
    var photoErrorMessage: String?

    let isCreating: Bool
    private let original: ProfileDraft
    private let profile: Profile?
    private var photoTask: Task<Void, Never>?

    init(profile: Profile?) {
        self.profile = profile
        let initial = profile.map { ProfileDraft(profile: $0) } ?? ProfileDraft()
        draft = initial
        original = initial
        isCreating = profile == nil
    }

    var isDirty: Bool { draft != original }

    var cardContent: CardContent { CardContent(draft: draft) }

    /// Format errors show as soon as a value is typed; "required" waits until the user tries to save.
    func errorMessage(for field: ProfileDraft.Field) -> String? {
        guard let error = draft.validationErrors()[field] else { return nil }
        if error == .required && !hasAttemptedSave { return nil }
        return error.message
    }

    func addSocialLink() {
        guard draft.socialLinks.count < ProfileDraft.maximumSocialLinks else { return }
        let used = Set(draft.socialLinks.map(\.platform))
        let platform = SocialPlatform.allCases.first { !used.contains($0) } ?? .other
        draft.socialLinks.append(.init(platform: platform))
    }

    func addProject() {
        guard draft.projects.count < ProfileDraft.maximumProjects else { return }
        draft.projects.append(.init())
    }

    func removePhoto() {
        photoTask?.cancel()
        photoSelection = nil
        draft.photoData = nil
    }

    /// Returns true when the profile was saved and the editor can close.
    func save(using repository: ProfileRepository) -> Bool {
        hasAttemptedSave = true
        guard draft.isValid else {
            saveState = .failed("Fix the highlighted fields to save.")
            return false
        }
        saveState = .saving
        do {
            try repository.save(draft, to: profile)
            saveState = .idle
            return true
        } catch {
            saveState = .failed("Your changes couldn't be saved. Please try again.")
            return false
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem) {
        photoTask?.cancel()
        isProcessingPhoto = true
        photoErrorMessage = nil
        photoTask = Task {
            defer { isProcessingPhoto = false }
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    throw PhotoProcessingError.unreadableImage
                }
                let prepared = try await PhotoProcessingService.prepareProfilePhoto(from: data)
                try Task.checkCancellation()
                draft.photoData = prepared
            } catch is CancellationError {
                return
            } catch {
                photoErrorMessage = "That photo couldn't be used. Try a different one."
            }
        }
    }
}
