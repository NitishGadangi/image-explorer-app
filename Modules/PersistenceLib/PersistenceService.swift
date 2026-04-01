import Foundation

public protocol PersistenceService: Sendable {
    func save<T: Encodable>(_ object: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}

public final class DefaultPersistenceService: PersistenceService {
    private let store: DataStore

    public init(store: DataStore) {
        self.store = store
    }

    public func save<T: Encodable>(_ object: T, forKey key: String) throws {
        try store.save(object, forKey: key)
    }

    public func load<T: Decodable>(forKey key: String) throws -> T? {
        try store.load(forKey: key)
    }

    public func delete(forKey key: String) throws {
        try store.delete(forKey: key)
    }

    public func exists(forKey key: String) -> Bool {
        store.exists(forKey: key)
    }
}
