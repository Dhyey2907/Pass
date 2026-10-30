import Foundation
import SwiftData
import Testing
@testable import Pass

@MainActor
struct SampleConnectionsTests {
    private let container: ModelContainer
    private let repository: ConnectionRepository

    init() throws {
        container = try PassPersistence.makeContainer(inMemory: true)
        repository = ConnectionRepository(context: container.mainContext)
    }

    private func allConnections() throws -> [Connection] {
        try container.mainContext.fetch(FetchDescriptor<Connection>())
    }

    @Test func samplesAreValidAndUseReservedDomains() {
        for sample in SampleConnections.all {
            #expect(sample.email.hasSuffix("@example.com"), "\(sample.slug)")
            #expect(sample.website.hasSuffix("example.com"), "\(sample.slug)")
            if let id = sample.backgroundID {
                #expect(CardBackgroundCatalog.preset(withID: id) != nil, "\(sample.slug)")
            }
            for (platform, handle) in sample.socials {
                #expect(platform.profileURL(from: handle) != nil, "\(sample.slug) \(platform)")
            }
        }
        #expect(Set(SampleConnections.all.map(\.slug)).count == SampleConnections.all.count)
    }

    @Test func loadingIsIdempotentAndMarksSamples() throws {
        try repository.loadSamples()
        try repository.loadSamples()
        let connections = try allConnections()
        #expect(connections.count == SampleConnections.all.count)
        #expect(connections.allSatisfy { $0.isSample })
        #expect(connections.allSatisfy { SampleConnections.sample(for: $0) != nil })
    }

    @Test func removingSamplesKeepsRealConnections() throws {
        let real = Connection(publicProfileURL: "https://pass.example.org/p/abc123", fullName: "Real Person")
        container.mainContext.insert(real)
        try repository.loadSamples()

        try repository.removeSamples()

        let remaining = try allConnections()
        #expect(remaining.map(\.fullName) == ["Real Person"])
        #expect(!real.isSample)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<SocialLink>()) == 0)
    }

    @Test func connectionRendersThroughSharedCardRenderer() throws {
        try repository.loadSamples()
        for connection in try allConnections() {
            let content = CardContent(draft: ProfileDraft(connection: connection))
            #expect(content.fullName == connection.fullName)
            #expect(!content.lines(limit: 4).isEmpty)
        }
    }
}
