import Foundation

public enum PersistenceError: LocalizedError, Sendable {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case storeFailed(Error)
    case notFound

    public var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .storeFailed(let error):
            return "Store operation failed: \(error.localizedDescription)"
        case .notFound:
            return "Data not found"
        }
    }
}
