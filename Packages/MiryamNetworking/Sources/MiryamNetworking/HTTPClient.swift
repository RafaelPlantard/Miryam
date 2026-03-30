import Foundation
import MiryamCore
import os

private let logger = Log.network

/// Actor-based HTTP client with retry, timeout, and rate-limit handling.
public actor HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let maxRetries: Int

    private enum RetryConstants {
        static let defaultTimeout: TimeInterval = 15
        static let resourceTimeout: TimeInterval = 30
        static let baseRetryDelay: UInt64 = 1_000_000_000 // 1 second in nanoseconds
    }

    public init(
        session: URLSession? = nil,
        maxRetries: Int = 2
    ) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = RetryConstants.defaultTimeout
            configuration.timeoutIntervalForResource = RetryConstants.resourceTimeout
            self.session = URLSession(configuration: configuration)
        }
        self.decoder = JSONDecoder()
        self.maxRetries = maxRetries
    }

    func fetch<T: Decodable & Sendable>(_ url: URL) async throws(AppError) -> T {
        var lastError: AppError = .networkError("Request failed")

        logger.debug("Request: \(url.absoluteString)")

        let retryLimit = maxRetries
        for attempt in 0 ... retryLimit {
            if attempt > 0 {
                logger.info("Retry \(attempt)/\(retryLimit) for: \(url.absoluteString)")
                let delay = RetryConstants.baseRetryDelay * UInt64(1 << (attempt - 1))
                try? await Task.sleep(nanoseconds: delay)
                guard !Task.isCancelled else { throw lastError }
            }

            do {
                return try await performRequest(url)
            } catch {
                lastError = error
                guard shouldRetry(error: error, attempt: attempt) else {
                    logger.error("Request failed: \(error)")
                    throw error
                }
            }
        }

        logger.error("Request failed after \(retryLimit) retries: \(lastError)")
        throw lastError
    }

    // MARK: - Private

    private func performRequest<T: Decodable & Sendable>(_ url: URL) async throws(AppError) -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            throw .networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .networkError("Invalid response")
        }

        guard APIConstants.HTTP.successRange.contains(httpResponse.statusCode) else {
            throw mapStatusCode(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw .decodingError(error.localizedDescription)
        }
    }

    private func shouldRetry(error: AppError, attempt: Int) -> Bool {
        guard attempt < maxRetries else { return false }
        switch error {
        case let .serverError(statusCode) where statusCode >= 500 || statusCode == 429:
            return true
        case .networkError:
            return true
        default:
            return false
        }
    }

    private func mapURLError(_ error: URLError) -> AppError {
        switch error.code {
        case .notConnectedToInternet, .dataNotAllowed:
            return .noInternetConnection
        case .timedOut:
            return .networkError("Request timed out")
        case .networkConnectionLost:
            return .networkError("Network connection lost")
        case .cannotConnectToHost, .cannotFindHost:
            return .networkError("Cannot connect to server")
        default:
            return .networkError(error.localizedDescription)
        }
    }

    private func mapStatusCode(_ statusCode: Int) -> AppError {
        switch statusCode {
        case APIConstants.HTTP.notFound:
            return .notFound
        case 429:
            return .serverError(statusCode: 429)
        default:
            return .serverError(statusCode: statusCode)
        }
    }
}
