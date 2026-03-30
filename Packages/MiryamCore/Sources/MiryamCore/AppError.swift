import Foundation

/// Unified error type used across all packages.
public enum AppError: Error, Sendable, Equatable {
    case networkError(String)
    case decodingError(String)
    case noInternetConnection
    case serverError(statusCode: Int)
    case notFound
    case playbackFailed(String)
    case cacheError(String)
    case unknown(String)

    public var userMessage: String {
        switch self {
        case .networkError:
            return "Unable to connect. Please check your internet connection."
        case .decodingError:
            return "Something went wrong while loading data."
        case .noInternetConnection:
            return "No internet connection. Showing cached results."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .notFound:
            return "No results found."
        case .playbackFailed:
            return "Unable to play this song. Please try another."
        case .cacheError:
            return "Unable to access saved data."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
