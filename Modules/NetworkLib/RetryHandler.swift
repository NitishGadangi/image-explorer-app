import Foundation

public struct RetryHandler: Sendable {
    public let maxRetries: Int
    public let baseBackoff: TimeInterval

    public init(maxRetries: Int = 0, baseBackoff: TimeInterval = 1.0) {
        self.maxRetries = maxRetries
        self.baseBackoff = baseBackoff
    }

    public func perform<T>(
        shouldRetry: @Sendable @escaping (Error) -> Bool,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        var lastError: Error!
        for attempt in 0...maxRetries {
            if attempt > 0 {
                let delay = baseBackoff * pow(2.0, Double(attempt - 1))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            do {
                return try await operation()
            } catch {
                lastError = error
                if !shouldRetry(error) { throw error }
            }
        }
        throw lastError
    }
}
