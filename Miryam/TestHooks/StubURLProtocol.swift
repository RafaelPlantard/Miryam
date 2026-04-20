#if DEBUG
    import Foundation

    /// Intercepts all URL requests and returns matching JSON fixture bodies.
    /// Used exclusively during UI tests to avoid hitting the live iTunes API.
    ///
    /// Fixture content is passed from the XCUITest bundle via `launchEnvironment`
    /// under `MIRYAM_FIXTURE_<name>` keys — so fixtures never ship in Release.
    final class StubURLProtocol: URLProtocol, @unchecked Sendable {
        /// Ordered list of (pattern, fixtureName) pairs.
        /// Patterns are matched against the full URL string in order — first match wins.
        nonisolated(unsafe) static var stubbedResponses: [(pattern: String, fixture: String)] = []

        private static let envPrefix = "MIRYAM_FIXTURE_"

        override static func canInit(with request: URLRequest) -> Bool {
            true
        }

        override static func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            guard let url = request.url,
                  let fixtureName = Self.matchFixture(for: url),
                  let json = ProcessInfo.processInfo.environment["\(Self.envPrefix)\(fixtureName)"],
                  let data = json.data(using: .utf8)
            else {
                client?.urlProtocol(self, didFailWithError: URLError(.fileDoesNotExist))
                client?.urlProtocolDidFinishLoading(self)
                return
            }

            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}

        private static func matchFixture(for url: URL) -> String? {
            let urlString = url.absoluteString
            for (pattern, fixture) in stubbedResponses where urlString.contains(pattern) {
                return fixture
            }
            return nil
        }
    }
#endif
