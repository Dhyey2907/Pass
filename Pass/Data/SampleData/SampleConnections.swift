import Foundation

/// Fictional contacts for demos. Marked by a reserved `example.com` URL (RFC 2606) so they can
/// never be mistaken for, or collide with, real scanned profiles.
enum SampleConnections {
    static let urlPrefix = "https://example.com/pass/sample/"

    struct Sample {
        let slug: String
        let fullName: String
        let designation: String
        let bio: String
        let email: String
        let website: String
        let template: CardTemplate
        let orientation: CardOrientation
        let backgroundID: String?
        let socials: [(SocialPlatform, String)]
        let projects: [(title: String, summary: String)]
        let notes: String
        let daysAgo: Int
    }

    static let all: [Sample] = [
        Sample(slug: "aarav-mehta", fullName: "Aarav Mehta", designation: "iOS Developer · CS Student",
               bio: "Building small apps that make campus life easier. Swift, SwiftUI and too much coffee.",
               email: "aarav@example.com", website: "aarav.example.com", template: .contrast, orientation: .vertical,
               backgroundID: "code-terminal", socials: [(.github, "aaravbuilds"), (.linkedIn, "aarav-mehta")],
               projects: [("StudyBuddy", "Pomodoro timer with group study rooms"), ("Campus Eats", "Live dining hall menus")],
               notes: "Met at the Swift meetup. Interested in collaborating on a hackathon.", daysAgo: 2),
        Sample(slug: "sofia-lindqvist", fullName: "Sofia Lindqvist", designation: "Product Designer",
               bio: "Designing calm, accessible products. Previously at a fintech studio.",
               email: "sofia@example.com", website: "sofia.example.com", template: .editorial, orientation: .vertical,
               backgroundID: "pro-marble", socials: [(.dribbble, "sofialind"), (.behance, "sofialind")],
               projects: [("Ledger", "Banking app redesign case study")],
               notes: "Portfolio review next Thursday.", daysAgo: 5),
        Sample(slug: "kwame-asante", fullName: "Kwame Asante", designation: "Founder, Northwind Labs",
               bio: "Helping small businesses go digital. Always happy to talk startups.",
               email: "kwame@example.com", website: "northwind.example.com", template: .essential, orientation: .horizontal,
               backgroundID: "car-racing-stripes", socials: [(.linkedIn, "kwame-asante"), (.x, "kwamebuilds")],
               projects: [("Northwind POS", "Point of sale for market vendors")],
               notes: "Hiring a mobile intern this summer.", daysAgo: 9),
        Sample(slug: "mei-tanaka", fullName: "Mei Tanaka", designation: "ML Researcher",
               bio: "Working on efficient on-device language models.",
               email: "mei@example.com", website: "mei.example.com", template: .editorial, orientation: .vertical,
               backgroundID: "code-circuit", socials: [(.github, "meitanaka-ml"), (.linkedIn, "mei-tanaka")],
               projects: [("TinyLM", "Language model that runs on a phone"), ("Paper notes", "Weekly ML paper summaries")],
               notes: "Sent her the dataset link.", daysAgo: 14),
        Sample(slug: "diego-ramirez", fullName: "Diego Ramírez", designation: "Content Creator",
               bio: "Tech reviews and car builds. 200k on YouTube.",
               email: "diego@example.com", website: "diego.example.com", template: .contrast, orientation: .vertical,
               backgroundID: "hero-scarlet-speed", socials: [(.youTube, "diegobuilds"), (.instagram, "diego.builds"), (.tikTok, "diegobuilds")],
               projects: [("Garage Diaries", "Weekly project car series")],
               notes: "Possible sponsored video.", daysAgo: 21),
        Sample(slug: "hannah-okoye", fullName: "Hannah Okoye", designation: "Marketing Lead",
               bio: "Brand strategy for consumer apps. Speaker and mentor.",
               email: "hannah@example.com", website: "hannah.example.com", template: .essential, orientation: .vertical,
               backgroundID: "pro-navy-pinstripe", socials: [(.linkedIn, "hannah-okoye")],
               projects: [], notes: "", daysAgo: 30),
        Sample(slug: "liam-oconnor", fullName: "Liam O'Connor", designation: "Automotive Engineer",
               bio: "EV powertrains by day, track days by weekend.",
               email: "liam@example.com", website: "liam.example.com", template: .contrast, orientation: .horizontal,
               backgroundID: "car-carbon", socials: [(.linkedIn, "liam-oconnor-ev")],
               projects: [("Battery thermal model", "Open simulation of pack cooling")],
               notes: "Talked about EV battery cooling.", daysAgo: 45),
        Sample(slug: "zara-khan", fullName: "Zara Khan", designation: "CS Student · Hackathon Organiser",
               bio: "Running the biggest student hackathon in the city. Come build with us!",
               email: "zara@example.com", website: "zara.example.com", template: .editorial, orientation: .vertical,
               backgroundID: "hero-cosmic", socials: [(.github, "zarakhan-dev"), (.instagram, "zara.codes")],
               projects: [("HackCity", "48-hour student hackathon"), ("Mentor Match", "Pairs first-timers with mentors")],
               notes: "Judge at HackCity in March?", daysAgo: 60),
    ]

    static func sample(for connection: Connection) -> Sample? {
        guard connection.isSample else { return nil }
        let slug = connection.publicProfileURL.dropFirst(urlPrefix.count)
        return all.first { $0.slug == slug }
    }
}

extension Connection {
    var isSample: Bool { publicProfileURL.hasPrefix(SampleConnections.urlPrefix) }
}
