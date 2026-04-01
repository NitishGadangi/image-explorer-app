import XCTest
import Foundation
@testable import MainListImpl
@testable import MainListInterface
@testable import NetworkLib
@testable import PersistenceLib

// MARK: - Mocks

final class MockNetworkService: NetworkService, @unchecked Sendable {
    var configuration = NetworkConfiguration()
    var result: Any?
    var error: Error?
    var requestCallCount = 0

    func request<T: Decodable & Sendable>(endpoint: Endpoint) async throws -> T {
        requestCallCount += 1
        if let error { throw error }
        return result as! T
    }
}

final class MockPersistenceService: PersistenceService, @unchecked Sendable {
    var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func save<T: Encodable>(_ object: T, forKey key: String) throws {
        storage[key] = try encoder.encode(object)
    }

    func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = storage[key] else { return nil }
        return try decoder.decode(T.self, from: data)
    }

    func delete(forKey key: String) throws {
        storage.removeValue(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        storage[key] != nil
    }
}

// MARK: - Tests

@MainActor
final class MainListViewModelTests: XCTestCase {

    private var mockNetwork: MockNetworkService!
    private var mockPersistence: MockPersistenceService!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkService()
        mockPersistence = MockPersistenceService()
    }

    private func makeViewModel(
        onProductSelected: @escaping (Product) -> Void = { _ in }
    ) -> MainListViewModel {
        MainListViewModel(
            networkService: mockNetwork,
            persistenceService: mockPersistence,
            onProductSelected: onProductSelected
        )
    }

    func testLoadsProductsFromNetwork() async {
        let products = [
            Product(team: 1, title: "iPhone", description: "A phone", thumbnail: "https://img.com/t.jpg", image: "https://img.com/f.jpg"),
        ]
        mockNetwork.result = ProductsResponse(products: products)

        let vm = makeViewModel()
        await vm.loadProducts()

        XCTAssertEqual(vm.products.count, 1)
        XCTAssertEqual(vm.products[0].title, "iPhone")
        XCTAssertNil(vm.errorMessage)
    }

    func testShowsCachedDataWhenNetworkFails() async throws {
        let cached = [
            Product(team: 1, title: "Cached", description: nil, thumbnail: "https://img.com/t.jpg", image: nil),
        ]
        try mockPersistence.save(cached, forKey: "cached_products")
        mockNetwork.error = NetworkError.noInternet

        let vm = makeViewModel()
        await vm.loadProducts()

        XCTAssertEqual(vm.products.count, 1)
        XCTAssertEqual(vm.products[0].title, "Cached")
        XCTAssertNil(vm.errorMessage)
    }

    func testShowsErrorWhenNetworkFailsAndNoCache() async {
        mockNetwork.error = NetworkError.noInternet

        let vm = makeViewModel()
        await vm.loadProducts()

        XCTAssertTrue(vm.products.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
    }

    func testFiltersProductsBySearchText() async {
        let products = [
            Product(team: 1, title: "iPhone 15", description: nil, thumbnail: "https://img.com/1.jpg", image: nil),
            Product(team: 1, title: "MacBook Pro", description: nil, thumbnail: "https://img.com/2.jpg", image: nil),
            Product(team: 2, title: "iPhone 14", description: nil, thumbnail: "https://img.com/3.jpg", image: nil),
        ]
        mockNetwork.result = ProductsResponse(products: products)

        let vm = makeViewModel()
        await vm.loadProducts()
        vm.searchText = "iPhone"

        XCTAssertEqual(vm.filteredProducts.count, 2)
        XCTAssertTrue(vm.filteredProducts.allSatisfy { $0.title.contains("iPhone") })
    }

    func testEmptySearchReturnsAllProducts() async {
        let products = [
            Product(team: 1, title: "A", description: nil, thumbnail: "https://img.com/1.jpg", image: nil),
            Product(team: 1, title: "B", description: nil, thumbnail: "https://img.com/2.jpg", image: nil),
        ]
        mockNetwork.result = ProductsResponse(products: products)

        let vm = makeViewModel()
        await vm.loadProducts()
        vm.searchText = ""

        XCTAssertEqual(vm.filteredProducts.count, 2)
    }

    func testFiltersOutNonDisplayableProducts() async {
        let products: [Product?] = [
            Product(team: 1, title: "Has Image", description: nil, thumbnail: "https://img.com/t.jpg", image: nil),
            Product(team: 2, title: "No Image", description: nil, thumbnail: nil, image: nil),
            nil,
        ]
        mockNetwork.result = ProductsResponse(products: products)

        let vm = makeViewModel()
        await vm.loadProducts()

        XCTAssertEqual(vm.products.count, 1)
        XCTAssertEqual(vm.products[0].title, "Has Image")
    }

    func testSelectProductCallsCallback() async {
        var selected: Product?
        let vm = makeViewModel { selected = $0 }

        let product = Product(team: 1, title: "Test", description: nil, thumbnail: "https://img.com/t.jpg", image: nil)
        mockNetwork.result = ProductsResponse(products: [product])
        await vm.loadProducts()
        vm.selectProduct(vm.products[0])

        XCTAssertNotNil(selected)
        XCTAssertEqual(selected?.title, "Test")
    }

    func testSelectRandomProductSelectsFromFilteredList() async {
        var selected: Product?
        let vm = makeViewModel { selected = $0 }

        let products = [
            Product(team: 1, title: "Alpha", description: nil, thumbnail: "https://img.com/1.jpg", image: nil),
            Product(team: 1, title: "Beta", description: nil, thumbnail: "https://img.com/2.jpg", image: nil),
        ]
        mockNetwork.result = ProductsResponse(products: products)
        await vm.loadProducts()
        vm.selectRandomProduct()

        XCTAssertNotNil(selected)
        XCTAssertTrue(["Alpha", "Beta"].contains(selected?.title))
    }

    func testSelectRandomProductDoesNothingWhenEmpty() {
        var selected: Product?
        let vm = makeViewModel { selected = $0 }

        vm.selectRandomProduct()
        XCTAssertNil(selected)
    }
}
