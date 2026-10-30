import UIKit

enum PhotoProcessingError: Error {
    case unreadableImage
}

enum PhotoProcessingService {
    static let profilePhotoDimension: CGFloat = 1024
    /// Covers a 3x export of the 540 pt card edge.
    static let backgroundDimension: CGFloat = 1620

    /// Downscales and re-encodes as JPEG off the main actor. Re-encoding also strips location metadata.
    static func prepareProfilePhoto(from data: Data) async throws -> Data {
        try await prepareImage(from: data, maximumDimension: profilePhotoDimension)
    }

    static func prepareBackground(from data: Data) async throws -> Data {
        try await prepareImage(from: data, maximumDimension: backgroundDimension)
    }

    private static func prepareImage(from data: Data, maximumDimension: CGFloat) async throws -> Data {
        try await Task.detached(priority: .userInitiated) {
            try resize(data, maximumDimension: maximumDimension)
        }.value
    }

    nonisolated private static func resize(_ data: Data, maximumDimension: CGFloat) throws -> Data {
        guard let image = UIImage(data: data) else { throw PhotoProcessingError.unreadableImage }
        let scale = min(1, maximumDimension / max(image.size.width, image.size.height))
        let size = CGSize(width: (image.size.width * scale).rounded(), height: (image.size.height * scale).rounded())
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        guard let jpeg = resized.jpegData(compressionQuality: 0.85) else { throw PhotoProcessingError.unreadableImage }
        return jpeg
    }
}
