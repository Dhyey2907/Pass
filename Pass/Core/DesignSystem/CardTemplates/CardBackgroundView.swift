import SwiftUI

/// Draws a built-in background preset at the card's canonical size.
struct CardBackgroundView: View {
    let preset: CardBackgroundPreset

    var body: some View {
        ZStack {
            fill
            if let pattern = preset.pattern {
                Canvas { context, size in
                    context.opacity = preset.patternOpacity
                    BackgroundPatternRenderer.draw(pattern, color: Color(hex: preset.patternColor), in: &context, size: size)
                }
            }
            if let symbol = preset.symbol {
                GeometryReader { proxy in
                    Image(systemName: symbol)
                        .font(.system(size: min(proxy.size.width, proxy.size.height) * 0.62, weight: .bold))
                        .foregroundStyle(preset.tone == .dark ? Color.white : Color.black)
                        .opacity(0.07)
                        .rotationEffect(.degrees(-12))
                        .position(x: proxy.size.width * 0.78, y: proxy.size.height * 0.3)
                }
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder private var fill: some View {
        switch preset.fill {
        case .linear(let colors):
            LinearGradient(colors: colors.map { Color(hex: $0) }, startPoint: .topLeading, endPoint: .bottomTrailing)
        case .radial(let colors):
            GeometryReader { proxy in
                RadialGradient(
                    colors: colors.map { Color(hex: $0) },
                    center: UnitPoint(x: 0.7, y: 0.25),
                    startRadius: 0,
                    endRadius: max(proxy.size.width, proxy.size.height)
                )
            }
        }
    }
}

/// Deterministic generator so seeded patterns look identical in preview and export.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state ^ (state >> 29)
    }
}

enum BackgroundPatternRenderer {
    static func draw(_ pattern: BackgroundPattern, color: Color, in context: inout GraphicsContext, size: CGSize) {
        let shading = GraphicsContext.Shading.color(color)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let reach = hypot(size.width, size.height)

        switch pattern {
        case .stripes(let angle, let width, let gap):
            var rotated = context
            rotated.translateBy(x: center.x, y: center.y)
            rotated.rotate(by: .degrees(angle))
            var path = Path()
            var x = -reach
            while x < reach {
                path.addRect(CGRect(x: x, y: -reach, width: width, height: reach * 2))
                x += width + gap
            }
            rotated.fill(path, with: shading)

        case .racingStripes(let width, let gap):
            let left = center.x - gap / 2 - width
            var path = Path()
            path.addRect(CGRect(x: left, y: 0, width: width, height: size.height))
            path.addRect(CGRect(x: center.x + gap / 2, y: 0, width: width, height: size.height))
            context.fill(path, with: shading)

        case .dots(let spacing, let radius):
            var path = Path()
            for x in stride(from: spacing / 2, to: size.width, by: spacing) {
                for y in stride(from: spacing / 2, to: size.height, by: spacing) {
                    path.addEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
                }
            }
            context.fill(path, with: shading)

        case .grid(let spacing):
            var path = Path()
            for x in stride(from: 0, through: size.width, by: spacing) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: spacing) {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: shading, lineWidth: 0.75)

        case .rays(let count):
            let origin = CGPoint(x: size.width * 0.5, y: size.height * 0.35)
            let step = (2 * Double.pi) / Double(count * 2)
            var path = Path()
            for index in 0..<count {
                let start = Double(index * 2) * step
                path.move(to: origin)
                path.addLine(to: point(from: origin, angle: start, distance: reach))
                path.addLine(to: point(from: origin, angle: start + step, distance: reach))
                path.closeSubpath()
            }
            context.fill(path, with: shading)

        case .web(let spokes, let ringSpacing):
            let origin = CGPoint(x: size.width * 0.85, y: size.height * 0.12)
            let angles = (0..<spokes).map { Double($0) * 2 * .pi / Double(spokes) }
            var path = Path()
            for angle in angles {
                path.move(to: origin)
                path.addLine(to: point(from: origin, angle: angle, distance: reach))
            }
            for radius in stride(from: ringSpacing, to: reach, by: ringSpacing) {
                for (index, angle) in angles.enumerated() {
                    let p = point(from: origin, angle: angle, distance: radius)
                    if index == 0 { path.move(to: p) } else { path.addLine(to: p) }
                }
                path.closeSubpath()
            }
            context.stroke(path, with: shading, lineWidth: 1.2)

        case .halftone(let spacing):
            var path = Path()
            for x in stride(from: spacing / 2, to: size.width, by: spacing) {
                for y in stride(from: spacing / 2, to: size.height, by: spacing) {
                    let t = (x / size.width + (1 - y / size.height)) / 2
                    let radius = spacing * 0.48 * t
                    path.addEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
                }
            }
            context.fill(path, with: shading)

        case .rings(let spacing):
            let origin = CGPoint(x: size.width * 0.7, y: size.height * 0.25)
            var path = Path()
            for radius in stride(from: spacing, to: reach, by: spacing) {
                path.addEllipse(in: CGRect(x: origin.x - radius, y: origin.y - radius, width: radius * 2, height: radius * 2))
            }
            context.stroke(path, with: shading, lineWidth: 1.5)

        case .waves(let count):
            var path = Path()
            for line in 0..<count {
                let baseY = size.height * (Double(line) + 0.5) / Double(count)
                path.move(to: CGPoint(x: 0, y: baseY))
                for x in stride(from: 0, through: size.width, by: 4) {
                    let y = baseY + sin(x / size.width * 2 * .pi + Double(line) * 0.7) * 14
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            context.stroke(path, with: shading, lineWidth: 1.5)

        case .checker(let squareSize):
            var path = Path()
            for (rowIndex, y) in stride(from: 0, to: size.height, by: squareSize).enumerated() {
                for (columnIndex, x) in stride(from: 0, to: size.width, by: squareSize).enumerated()
                where (rowIndex + columnIndex).isMultiple(of: 2) {
                    path.addRect(CGRect(x: x, y: y, width: squareSize, height: squareSize))
                }
            }
            context.fill(path, with: shading)

        case .circuit(let seed):
            var rng = SeededGenerator(state: seed)
            var traces = Path()
            var pads = Path()
            for _ in 0..<28 {
                var p = CGPoint(x: snap(Double.random(in: 0...size.width, using: &rng)), y: snap(Double.random(in: 0...size.height, using: &rng)))
                traces.move(to: p)
                pads.addEllipse(in: CGRect(x: p.x - 3, y: p.y - 3, width: 6, height: 6))
                for _ in 0..<3 {
                    let length = snap(Double.random(in: 20...90, using: &rng))
                    switch Int.random(in: 0..<3, using: &rng) {
                    case 0: p.x += Bool.random(using: &rng) ? length : -length
                    case 1: p.y += Bool.random(using: &rng) ? length : -length
                    default:
                        p.x += length * 0.7
                        p.y += Bool.random(using: &rng) ? length * 0.7 : -length * 0.7
                    }
                    traces.addLine(to: p)
                }
                pads.addEllipse(in: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8))
            }
            context.stroke(traces, with: shading, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            context.fill(pads, with: shading)

        case .codeRain(let seed, let glyphs):
            var rng = SeededGenerator(state: seed)
            let characters = Array(glyphs)
            guard !characters.isEmpty else { return }
            let resolved = Dictionary(characters.map { character in
                (character, context.resolve(Text(String(character)).font(.system(size: 12, weight: .medium, design: .monospaced)).foregroundStyle(color)))
            }, uniquingKeysWith: { first, _ in first })
            for x in stride(from: 8.0, to: size.width, by: 16) {
                var y = Double.random(in: -120...size.height * 0.6, using: &rng)
                let length = Int.random(in: 6...22, using: &rng)
                for index in 0..<length {
                    guard let character = characters.randomElement(using: &rng), let text = resolved[character] else { continue }
                    var faded = context
                    faded.opacity *= 1 - Double(index) / Double(length)
                    faded.draw(text, at: CGPoint(x: x, y: y))
                    y += 15
                }
            }

        case .speedLines(let seed):
            var rng = SeededGenerator(state: seed)
            for _ in 0..<46 {
                let y = Double.random(in: 0...size.height, using: &rng)
                let length = Double.random(in: size.width * 0.2...size.width * 0.9, using: &rng)
                let x = Double.random(in: -length * 0.3...size.width, using: &rng)
                var line = Path()
                line.move(to: CGPoint(x: x, y: y))
                line.addLine(to: CGPoint(x: x + length, y: y))
                var faded = context
                faded.opacity *= Double.random(in: 0.3...1, using: &rng)
                faded.stroke(line, with: shading, style: StrokeStyle(lineWidth: Double.random(in: 0.5...2.5, using: &rng), lineCap: .round))
            }

        case .stars(let seed):
            var rng = SeededGenerator(state: seed)
            var path = Path()
            for _ in 0..<140 {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let radius = Double.random(in: 0.4...1.8, using: &rng)
                path.addEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
            }
            context.fill(path, with: shading)
        }
    }

    private static func point(from origin: CGPoint, angle: Double, distance: Double) -> CGPoint {
        CGPoint(x: origin.x + cos(angle) * distance, y: origin.y + sin(angle) * distance)
    }

    private static func snap(_ value: Double) -> Double {
        (value / 10).rounded() * 10
    }
}
