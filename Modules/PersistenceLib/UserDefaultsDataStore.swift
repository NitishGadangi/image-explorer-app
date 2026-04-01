import Foundation

public final class UserDefaultsDataStore: DataStore, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        suiteName: String? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        if let suiteName {
            self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            self.defaults = .standard
        }
        self.encoder = encoder
        self.decoder = decoder
    }

    public func save<T: Encodable>(_ object: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(object)
            defaults.set(data, forKey: key)
        } catch let error as EncodingError {
            throw PersistenceError.encodingFailed(error)
        } catch {
            throw PersistenceError.storeFailed(error)
        }
    }

    public func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw PersistenceError.decodingFailed(error)
        }
    }

    public func delete(forKey key: String) throws {
        defaults.removeObject(forKey: key)
    }

    public func exists(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}
