import Foundation
import MiryamCore

/// Actor-based HTTP client for making network requests.
public actor HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetch<T: Decodable & Sendable>(_ url: URL) async throws(AppError) -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw .noInternetConnection
        } catch {
            throw .networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .networkError("Invalid response")
        }

        guard APIConstants.HTTP.successRange.contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == APIConstants.HTTP.notFound {
                throw .notFound
            }
            throw .serverError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw .decodingError(error.localizedDescription)
        }
    }
}
