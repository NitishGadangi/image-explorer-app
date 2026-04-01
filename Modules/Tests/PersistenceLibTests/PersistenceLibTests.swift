import XCTest
import Foundation
@testable import PersistenceLib

final class UserDefaultsDataStoreTests: XCTestCase {

    private var store: UserDefaultsDataStore!

    override func setUp() {
        super.setUp()
        store = UserDefaultsDataStore(suiteName: "com.test.persistence.\(UUID().uuidString)")
    }

    func testSaveAndLoad() throws {
        let data = "hello".data(using: .utf8)!
        try store.save(data, forKey: "test")
        let loaded = try store.load(forKey: "test")
        XCTAssertEqual(loaded, data)
    }

    func testLoadReturnsNilForMissingKey() throws {
        let loaded = try store.load(forKey: "nonexistent")
        XCTAssertNil(loaded)
    }

    func testDeleteRemovesData() throws {
        let data = "hello".data(using: .utf8)!
        try store.save(data, forKey: "test")
        try store.delete(forKey: "test")
        XCTAssertNil(try store.load(forKey: "test"))
    }

    func testExistsReturnsCorrectValue() throws {
        XCTAssertFalse(store.exists(forKey: "test"))
        try store.save("data".data(using: .utf8)!, forKey: "test")
        XCTAssertTrue(store.exists(forKey: "test"))
    }
}

final class DefaultPersistenceServiceTests: XCTestCase {

    private var service: DefaultPersistenceService!

    override func setUp() {
        super.setUp()
        let store = UserDefaultsDataStore(suiteName: "com.test.service.\(UUID().uuidString)")
        service = DefaultPersistenceService(store: store)
    }

    struct TestModel: Codable, Equatable {
        let name: String
        let value: Int
    }

    func testSaveAndLoadCodableObject() throws {
        let model = TestModel(name: "test", value: 42)
        try service.save(model, forKey: "model")
        let loaded: TestModel? = try service.load(forKey: "model")
        XCTAssertEqual(loaded, model)
    }

    func testLoadReturnsNilForMissingKey() throws {
        let loaded: TestModel? = try service.load(forKey: "missing")
        XCTAssertNil(loaded)
    }

    func testSaveAndLoadArray() throws {
        let models = [
            TestModel(name: "a", value: 1),
            TestModel(name: "b", value: 2),
        ]
        try service.save(models, forKey: "models")
        let loaded: [TestModel]? = try service.load(forKey: "models")
        XCTAssertEqual(loaded, models)
    }

    func testDeleteRemovesPersistedData() throws {
        let model = TestModel(name: "test", value: 1)
        try service.save(model, forKey: "model")
        try service.delete(forKey: "model")
        let loaded: TestModel? = try service.load(forKey: "model")
        XCTAssertNil(loaded)
    }

    func testExistsReflectsCurrentState() throws {
        XCTAssertFalse(service.exists(forKey: "key"))
        try service.save(TestModel(name: "x", value: 0), forKey: "key")
        XCTAssertTrue(service.exists(forKey: "key"))
    }
}
