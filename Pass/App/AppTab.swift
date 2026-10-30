import Foundation

enum AppTab: Hashable, CaseIterable {
    case myPass
    case scan
    case contacts
    case settings

    var title: String {
        switch self {
        case .myPass: "My Pass"
        case .scan: "Scan"
        case .contacts: "Contacts"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .myPass: "person.crop.rectangle"
        case .scan: "qrcode.viewfinder"
        case .contacts: "person.2"
        case .settings: "gearshape"
        }
    }
}
