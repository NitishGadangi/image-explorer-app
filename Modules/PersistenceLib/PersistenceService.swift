import Foundation

public protocol PersistenceService: Sendable {
    func save<T: Encodable>(_ object: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}

public final class DefaultPersistenceService: PersistenceService, @unchecked Sendable {
    private let store: DataStore
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        store: DataStore,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.store = store
        self.encoder = encoder
        self.decoder = decoder
    }

    public func save<T: Encodable>(_ object: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(object)
            try store.save(data, forKey: key)
        } catch let error as PersistenceError {
            throw error
        } catch let error as EncodingError {
            throw PersistenceError.encodingFailed(error)
        } catch {
            throw PersistenceError.storeFailed(error)
        }
    }

    public func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = try store.load(forKey: key) else { return nil }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw PersistenceError.decodingFailed(error)
        }
    }

    public func delete(forKey key: String) throws {
        try store.delete(forKey: key)
    }

    public func exists(forKey key: String) -> Bool {
        store.exists(forKey: key)
    }
}
