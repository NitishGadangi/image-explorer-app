import XCTest
import Foundation
@testable import PersistenceLib

struct TestModel: Codable, Equatable {
    let name: String
    let value: Int
}

final class UserDefaultsDataStoreTests: XCTestCase {

    private var store: UserDefaultsDataStore!

    override func setUp() {
        super.setUp()
        store = UserDefaultsDataStore(suiteName: "com.test.persistence.\(UUID().uuidString)")
    }

    func testSaveAndLoad() throws {
        let model = TestModel(name: "hello", value: 1)
        try store.save(model, forKey: "test")
        let loaded: TestModel? = try store.load(forKey: "test")
        XCTAssertEqual(loaded, model)
    }

    func testLoadReturnsNilForMissingKey() throws {
        let loaded: TestModel? = try store.load(forKey: "nonexistent")
        XCTAssertNil(loaded)
    }

    func testDeleteRemovesData() throws {
        let model = TestModel(name: "hello", value: 1)
        try store.save(model, forKey: "test")
        try store.delete(forKey: "test")
        let loaded: TestModel? = try store.load(forKey: "test")
        XCTAssertNil(loaded)
    }

    func testExistsReturnsCorrectValue() throws {
        XCTAssertFalse(store.exists(forKey: "test"))
        try store.save(TestModel(name: "x", value: 0), forKey: "test")
        XCTAssertTrue(store.exists(forKey: "test"))
    }

    func testSaveAndLoadArray() throws {
        let models = [
            TestModel(name: "a", value: 1),
            TestModel(name: "b", value: 2),
        ]
        try store.save(models, forKey: "models")
        let loaded: [TestModel]? = try store.load(forKey: "models")
        XCTAssertEqual(loaded, models)
    }
}

final class DefaultPersistenceServiceTests: XCTestCase {

    private var service: DefaultPersistenceService!

    override func setUp() {
        super.setUp()
        let store = UserDefaultsDataStore(suiteName: "com.test.service.\(UUID().uuidString)")
        service = DefaultPersistenceService(store: store)
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
