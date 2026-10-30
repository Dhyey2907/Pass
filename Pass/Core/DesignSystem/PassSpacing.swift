import CoreGraphics

enum PassSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32

    static let screenMargin: CGFloat = 24
    static let minimumTouchTarget: CGFloat = 44
}

enum PassRadius {
    static let card: CGFloat = 18
    static let button: CGFloat = 12
    static let control: CGFloat = 8
}

enum PassMotion {
    /// Card transitions run 250–350 ms per the motion spec.
    static let cardTransitionDuration: Double = 0.3
}
