import Foundation
import MiryamCore
import Testing

@testable import MiryamNetworking

// MARK: - Mock URLProtocol

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Test Helpers

private struct TestResponse: Decodable, Sendable {
    let message: String
}

private func makeSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    config.timeoutIntervalForRequest = 5
    config.timeoutIntervalForResource = 10
    return URLSession(configuration: config)
}

private func makeHTTPResponse(url: URL, statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
    )!
}

// MARK: - HTTPClient Tests

@Suite("HTTPClient", .serialized)
struct HTTPClientTests {

    @Test("Successful 200 response decodes correctly")
    func successfulResponseDecodes() async throws {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 0)
        let url = URL(string: "https://example.com/test")!

        MockURLProtocol.requestHandler = { request in
            let json = #"{"message": "hello"}"#
            let response = makeHTTPResponse(url: request.url!, statusCode: 200)
            return (response, Data(json.utf8))
        }

        let result: TestResponse = try await client.fetch(url)
        #expect(result.message == "hello")
    }

    @Test("404 response throws notFound error")
    func notFoundThrowsError() async {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 0)
        let url = URL(string: "https://example.com/missing")!

        MockURLProtocol.requestHandler = { request in
            let response = makeHTTPResponse(url: request.url!, statusCode: 404)
            return (response, Data())
        }

        do {
            let _: TestResponse = try await client.fetch(url)
            Issue.record("Expected notFound error")
        } catch {
            guard case .notFound = error else {
                Issue.record("Expected notFound, got \(error)")
                return
            }
        }
    }

    @Test("500 response throws serverError")
    func serverErrorThrows() async {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 0)
        let url = URL(string: "https://example.com/error")!

        MockURLProtocol.requestHandler = { request in
            let response = makeHTTPResponse(url: request.url!, statusCode: 500)
            return (response, Data())
        }

        do {
            let _: TestResponse = try await client.fetch(url)
            Issue.record("Expected serverError")
        } catch {
            guard case let .serverError(statusCode) = error else {
                Issue.record("Expected serverError, got \(error)")
                return
            }
            #expect(statusCode == 500)
        }
    }

    @Test("429 response triggers retry then succeeds")
    func rateLimitRetryThenSuccess() async throws {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 2)
        let url = URL(string: "https://example.com/rate-limited")!

        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            if callCount == 1 {
                let response = makeHTTPResponse(url: request.url!, statusCode: 429)
                return (response, Data())
            }
            let json = #"{"message": "success after retry"}"#
            let response = makeHTTPResponse(url: request.url!, statusCode: 200)
            return (response, Data(json.utf8))
        }

        let result: TestResponse = try await client.fetch(url)
        #expect(result.message == "success after retry")
        #expect(callCount == 2)
    }

    @Test("500 response retries and eventually succeeds")
    func serverErrorRetryThenSuccess() async throws {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 2)
        let url = URL(string: "https://example.com/flaky")!

        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            if callCount <= 2 {
                let response = makeHTTPResponse(url: request.url!, statusCode: 500)
                return (response, Data())
            }
            let json = #"{"message": "finally"}"#
            let response = makeHTTPResponse(url: request.url!, statusCode: 200)
            return (response, Data(json.utf8))
        }

        let result: TestResponse = try await client.fetch(url)
        #expect(result.message == "finally")
        #expect(callCount == 3)
    }

    @Test("Max retries exhausted throws last error")
    func maxRetriesExhaustedThrows() async {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 1)
        let url = URL(string: "https://example.com/always-fails")!

        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let response = makeHTTPResponse(url: request.url!, statusCode: 500)
            return (response, Data())
        }

        do {
            let _: TestResponse = try await client.fetch(url)
            Issue.record("Expected error after max retries")
        } catch {
            guard case let .serverError(statusCode) = error else {
                Issue.record("Expected serverError, got \(error)")
                return
            }
            #expect(statusCode == 500)
            #expect(callCount == 2) // initial + 1 retry
        }
    }

    @Test("Malformed JSON throws decodingError")
    func malformedJSONThrowsDecodingError() async {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 0)
        let url = URL(string: "https://example.com/bad-json")!

        MockURLProtocol.requestHandler = { request in
            let response = makeHTTPResponse(url: request.url!, statusCode: 200)
            return (response, Data("not json".utf8))
        }

        do {
            let _: TestResponse = try await client.fetch(url)
            Issue.record("Expected decodingError")
        } catch {
            guard case .decodingError = error else {
                Issue.record("Expected decodingError, got \(error)")
                return
            }
        }
    }

    @Test("Network error (not connected) throws noInternetConnection")
    func networkNotConnectedThrows() async {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 0)
        let url = URL(string: "https://example.com/offline")!

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let _: TestResponse = try await client.fetch(url)
            Issue.record("Expected noInternetConnection error")
        } catch {
            guard case .noInternetConnection = error else {
                Issue.record("Expected noInternetConnection, got \(error)")
                return
            }
        }
    }

    @Test("Network timeout throws networkError")
    func timeoutThrowsNetworkError() async {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 0)
        let url = URL(string: "https://example.com/timeout")!

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        do {
            let _: TestResponse = try await client.fetch(url)
            Issue.record("Expected networkError")
        } catch {
            guard case .networkError = error else {
                Issue.record("Expected networkError, got \(error)")
                return
            }
        }
    }

    @Test("404 does not retry")
    func notFoundDoesNotRetry() async {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 2)
        let url = URL(string: "https://example.com/not-found")!

        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let response = makeHTTPResponse(url: request.url!, statusCode: 404)
            return (response, Data())
        }

        do {
            let _: TestResponse = try await client.fetch(url)
            Issue.record("Expected notFound error")
        } catch {
            #expect(callCount == 1, "404 should not trigger retries")
        }
    }

    @Test("Zero maxRetries means no retries on server error")
    func zeroRetriesMeansNoRetry() async {
        let session = makeSession()
        let client = HTTPClient(session: session, maxRetries: 0)
        let url = URL(string: "https://example.com/no-retry")!

        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let response = makeHTTPResponse(url: request.url!, statusCode: 500)
            return (response, Data())
        }

        do {
            let _: TestResponse = try await client.fetch(url)
            Issue.record("Expected serverError")
        } catch {
            #expect(callCount == 1, "Zero retries means exactly 1 attempt")
        }
    }
}
