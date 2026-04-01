import Foundation

public protocol NetworkService: Sendable {
    var configuration: NetworkConfiguration { get }

    func request<T: Decodable & Sendable>(endpoint: Endpoint) async throws -> T
}
