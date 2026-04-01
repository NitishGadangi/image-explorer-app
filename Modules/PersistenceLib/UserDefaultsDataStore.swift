import Foundation

public final class UserDefaultsDataStore: DataStore, @unchecked Sendable {
    private let defaults: UserDefaults

    public init(suiteName: String? = nil) {
        if let suiteName {
            self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            self.defaults = .standard
        }
    }

    public func save(_ data: Data, forKey key: String) throws {
        defaults.set(data, forKey: key)
    }

    public func load(forKey key: String) throws -> Data? {
        defaults.data(forKey: key)
    }

    public func delete(forKey key: String) throws {
        defaults.removeObject(forKey: key)
    }

    public func exists(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}
