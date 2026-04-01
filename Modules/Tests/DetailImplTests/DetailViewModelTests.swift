import XCTest
import Foundation
@testable import DetailImpl
@testable import MainListInterface

@MainActor
final class DetailViewModelTests: XCTestCase {

    func testExposesCorrectImageURL() {
        let product = Product(
            team: 1, title: "Test", description: "Desc",
            thumbnail: "https://img.com/thumb.jpg",
            image: "https://img.com/full.jpg"
        )
        let vm = DetailViewModel(product: product)
        XCTAssertEqual(vm.imageURL?.absoluteString, "https://img.com/full.jpg")
    }

    func testFallsBackToThumbnailWhenImageIsNil() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: "https://img.com/thumb.jpg",
            image: nil
        )
        let vm = DetailViewModel(product: product)
        XCTAssertEqual(vm.imageURL?.absoluteString, "https://img.com/thumb.jpg")
    }

    func testTitleIsExposedCorrectly() {
        let product = Product(
            team: 1, title: "iPhone 15", description: nil,
            thumbnail: "https://img.com/t.jpg", image: nil
        )
        let vm = DetailViewModel(product: product)
        XCTAssertEqual(vm.title, "iPhone 15")
    }

    func testDescriptionIsNilWhenProductHasNone() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: "https://img.com/t.jpg", image: nil
        )
        let vm = DetailViewModel(product: product)
        XCTAssertNil(vm.description)
    }

    func testDescriptionIsPresentWhenProductHasOne() {
        let product = Product(
            team: 1, title: "Test", description: "A great product",
            thumbnail: "https://img.com/t.jpg", image: nil
        )
        let vm = DetailViewModel(product: product)
        XCTAssertEqual(vm.description, "A great product")
    }

    func testHasTitleReturnsTrueForNonEmptyTitle() {
        let product = Product(
            team: 1, title: "iPhone", description: nil,
            thumbnail: "https://img.com/t.jpg", image: nil
        )
        let vm = DetailViewModel(product: product)
        XCTAssertTrue(vm.hasTitle)
    }

    func testHasTitleReturnsFalseForEmptyTitle() {
        let product = Product(
            team: 1, title: "", description: nil,
            thumbnail: "https://img.com/t.jpg", image: nil
        )
        let vm = DetailViewModel(product: product)
        XCTAssertFalse(vm.hasTitle)
    }
}
