import PhotosUI
import SwiftUI

/// Category tabs over a grid of background thumbnails, plus "None" and "Upload your own".
struct BackgroundPicker: View {
    enum Tab: Hashable {
        case yours
        case category(CardBackgroundCategory)

        var title: String {
            switch self {
            case .yours: "Yours"
            case .category(let category): category.displayName
            }
        }
    }

    @Binding var backgroundID: String?
    @Binding var photoData: Data?

    @State private var tab: Tab
    @State private var photoItem: PhotosPickerItem?
    @State private var isProcessingPhoto = false
    @State private var photoError: String?

    private let tabs: [Tab] = [.yours] + CardBackgroundCategory.allCases.map(Tab.category)
    private let columns = [GridItem(.adaptive(minimum: 92), spacing: PassSpacing.s)]

    init(backgroundID: Binding<String?>, photoData: Binding<Data?>) {
        _backgroundID = backgroundID
        _photoData = photoData
        let category = backgroundID.wrappedValue.flatMap { CardBackgroundCatalog.preset(withID: $0) }?.category
        _tab = State(initialValue: category.map(Tab.category) ?? .yours)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PassSpacing.s) {
            PassMetadataLabel("Background")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PassSpacing.xs) {
                    ForEach(tabs, id: \.self) { option in
                        CategoryChip(title: option.title, isSelected: option == tab) { tab = option }
                    }
                }
            }

            LazyVGrid(columns: columns, spacing: PassSpacing.s) {
                switch tab {
                case .yours:
                    BackgroundTile(name: "None", isSelected: backgroundID == nil) {
                        backgroundID = nil
                    } thumbnail: {
                        ZStack {
                            PassColors.paper
                            Image(systemName: "circle.slash").foregroundStyle(PassColors.textSecondary)
                        }
                    }
                    uploadTile
                    if let image = photoData.flatMap(UIImage.init(data:)) {
                        BackgroundTile(name: "My photo", isSelected: backgroundID == CardBackgroundCatalog.customPhotoID) {
                            backgroundID = CardBackgroundCatalog.customPhotoID
                        } thumbnail: {
                            Image(uiImage: image).resizable().scaledToFill()
                        }
                    }
                case .category(let category):
                    ForEach(CardBackgroundCatalog.presets(in: category)) { preset in
                        BackgroundTile(name: preset.name, isSelected: backgroundID == preset.id) {
                            backgroundID = preset.id
                        } thumbnail: {
                            CanonicalScaledView(size: CardMetrics.canonicalSize(for: .vertical)) {
                                CardBackgroundView(preset: preset)
                            }
                        }
                    }
                }
            }

            if let photoError {
                FieldErrorText(message: photoError)
            }
        }
        .onChange(of: photoItem) { _, item in
            if let item { Task { await loadPhoto(item) } }
        }
    }

    private var uploadTile: some View {
        PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
            VStack(spacing: PassSpacing.xxs) {
                ZStack {
                    RoundedRectangle(cornerRadius: PassRadius.control, style: .continuous)
                        .strokeBorder(PassColors.accent, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    if isProcessingPhoto {
                        ProgressView()
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                            .foregroundStyle(PassColors.accent)
                    }
                }
                .aspectRatio(340.0 / 540.0, contentMode: .fit)
                Text("Upload")
                    .font(PassTypography.footnote)
                    .foregroundStyle(PassColors.textPrimary)
                    .lineLimit(1)
            }
        }
        .disabled(isProcessingPhoto)
        .accessibilityLabel("Upload your own background")
    }

    private func loadPhoto(_ item: PhotosPickerItem) async {
        isProcessingPhoto = true
        photoError = nil
        defer {
            isProcessingPhoto = false
            photoItem = nil
        }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw PhotoProcessingError.unreadableImage
            }
            photoData = try await PhotoProcessingService.prepareBackground(from: data)
            backgroundID = CardBackgroundCatalog.customPhotoID
        } catch {
            photoError = "That image couldn't be used. Try a different one."
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(PassTypography.callout.weight(.medium))
                .foregroundStyle(isSelected ? PassColors.onAccent : PassColors.textPrimary)
                .padding(.horizontal, PassSpacing.m)
                .frame(minHeight: 36)
                .background(
                    Capsule().fill(isSelected ? PassColors.accent : Color.clear)
                )
                .overlay(
                    Capsule().strokeBorder(isSelected ? Color.clear : PassColors.divider, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct BackgroundTile<Thumbnail: View>: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder var thumbnail: Thumbnail

    var body: some View {
        Button(action: action) {
            VStack(spacing: PassSpacing.xxs) {
                Color.clear
                    .aspectRatio(340.0 / 540.0, contentMode: .fit)
                    .overlay { thumbnail }
                    .clipShape(RoundedRectangle(cornerRadius: PassRadius.control, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: PassRadius.control, style: .continuous)
                            .strokeBorder(isSelected ? PassColors.accent : PassColors.divider, lineWidth: isSelected ? 3 : 1)
                    )
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(PassColors.onAccent, PassColors.accent)
                                .padding(PassSpacing.xxs)
                        }
                    }
                Text(name)
                    .font(PassTypography.footnote)
                    .foregroundStyle(PassColors.textPrimary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
