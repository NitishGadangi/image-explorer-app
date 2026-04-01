import Foundation

public struct NetworkConfiguration: Sendable {
    public let timeout: TimeInterval
    public let maxRetries: Int
    public let baseBackoff: TimeInterval

    public init(
        timeout: TimeInterval = 30,
        maxRetries: Int = 3,
        baseBackoff: TimeInterval = 1.0
    ) {
        self.timeout = timeout
        self.maxRetries = maxRetries
        self.baseBackoff = baseBackoff
    }
}
