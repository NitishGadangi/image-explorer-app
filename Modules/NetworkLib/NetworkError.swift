import Foundation

public enum NetworkError: LocalizedError, Sendable {
    case invalidURL
    case requestFailed(statusCode: Int, data: Data?)
    case decodingFailed(Error)
    case noData
    case timeout
    case noInternet
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let code, _):
            return "Request failed with status code: \(code)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .timeout:
            return "Request timed out"
        case .noInternet:
            return "No internet connection"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
