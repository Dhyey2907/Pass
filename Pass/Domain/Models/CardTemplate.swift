import Foundation

enum CardTemplate: String, CaseIterable, Codable, Identifiable {
    case editorial
    case essential
    case contrast

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .editorial: "Editorial"
        case .essential: "Essential"
        case .contrast: "Contrast"
        }
    }
}

enum CardOrientation: String, CaseIterable, Codable, Identifiable {
    case vertical
    case horizontal

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vertical: "Vertical"
        case .horizontal: "Horizontal"
        }
    }
}
