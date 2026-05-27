import Foundation
import Testing
@testable import GitCelebrate

struct GitHookHTTPParserTests {
    @Test
    func decodesHookPayloadFromHTTPRequest() {
        let request = """
        POST / HTTP/1.1\r
        Host: 127.0.0.1:4545\r
        Content-Type: application/json\r
        Content-Length: 67\r
        \r
        {"type":"commit","repo":"SampleApp","path":"/Users/dev/projects/SampleApp"}
        """

        let payload = GitHookHTTPParser().payload(from: Data(request.utf8))

        #expect(payload == GitHookPayload(type: .commit, repo: "SampleApp", path: "/Users/dev/projects/SampleApp"))
    }

    @Test
    func decodesHookPayloadWithMetadata() {
        let request = """
        POST / HTTP/1.1\r
        Host: 127.0.0.1:4545\r
        Content-Type: application/json\r
        \r
        {"type":"commit","repo":"SampleApp","path":"/Users/dev/projects/SampleApp","subject":"Add jump physics","filesChanged":2,"insertions":42,"deletions":7}
        """

        let payload = GitHookHTTPParser().payload(from: Data(request.utf8))

        #expect(payload?.subject == "Add jump physics")
        #expect(payload?.filesChanged == 2)
        #expect(payload?.insertions == 42)
        #expect(payload?.deletions == 7)
    }

    @Test
    func rejectsInvalidHTTPRequest() {
        let payload = GitHookHTTPParser().payload(from: Data("not http".utf8))

        #expect(payload == nil)
    }
}
