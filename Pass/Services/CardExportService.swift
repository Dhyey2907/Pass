import SwiftUI
import UniformTypeIdentifiers

enum CardExportError: Error {
    case renderFailed
}

/// Renders the same `CardView` used on screen into a PNG for sharing or saving.
enum CardExportService {
    static func renderPNG(content: CardContent, template: CardTemplate, orientation: CardOrientation) throws -> Data {
        let renderer = ImageRenderer(
            content: CardView(content: content, template: template, orientation: orientation)
                .padding(24)
                .background(PassColors.background)
        )
        renderer.scale = 3
        renderer.isOpaque = true
        guard let image = renderer.uiImage, let data = image.pngData() else { throw CardExportError.renderFailed }
        return data
    }
}

/// Lets ShareLink hand off a rendered card as a PNG file.
struct ExportedCardImage: Transferable {
    let data: Data
    let fileName: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { $0.data }
            .suggestedFileName { $0.fileName }
    }
}
