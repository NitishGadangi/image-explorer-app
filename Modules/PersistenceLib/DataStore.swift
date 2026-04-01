import Foundation

public protocol DataStore: Sendable {
    func save<T: Encodable>(_ object: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}
