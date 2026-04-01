import XCTest
import Foundation
@testable import MainListInterface

final class ProductDecodingTests: XCTestCase {

    func testDecodesValidProduct() throws {
        let json = """
        {"team": 1, "title": "iPhone", "description": "A phone", "thumbnail": "https://img.com/thumb.jpg", "image": "https://img.com/full.jpg"}
        """.data(using: .utf8)!

        let product = try JSONDecoder().decode(Product.self, from: json)
        XCTAssertEqual(product.team, 1)
        XCTAssertEqual(product.title, "iPhone")
        XCTAssertEqual(product.description, "A phone")
        XCTAssertEqual(product.thumbnail, "https://img.com/thumb.jpg")
        XCTAssertEqual(product.image, "https://img.com/full.jpg")
    }

    func testDecodesProductWithNullThumbnail() throws {
        let json = """
        {"team": 1, "title": "Test", "description": null, "thumbnail": null, "image": "https://img.com/full.jpg"}
        """.data(using: .utf8)!

        let product = try JSONDecoder().decode(Product.self, from: json)
        XCTAssertNil(product.thumbnail)
        XCTAssertEqual(product.image, "https://img.com/full.jpg")
    }

    func testDecodesProductWithMissingFields() throws {
        let json = """
        {"team": 2, "title": "Test"}
        """.data(using: .utf8)!

        let product = try JSONDecoder().decode(Product.self, from: json)
        XCTAssertNil(product.description)
        XCTAssertNil(product.thumbnail)
        XCTAssertNil(product.image)
    }

    func testDecodesProductWithEmptyStringImage() throws {
        let json = """
        {"team": 1, "title": "Test", "thumbnail": "", "image": ""}
        """.data(using: .utf8)!

        let product = try JSONDecoder().decode(Product.self, from: json)
        XCTAssertEqual(product.thumbnail, "")
        XCTAssertEqual(product.image, "")
    }
}

final class ProductDisplayURLTests: XCTestCase {

    func testDisplayThumbnailURLPrefersThumbnail() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: "https://img.com/thumb.jpg",
            image: "https://img.com/full.jpg"
        )
        XCTAssertEqual(product.displayThumbnailURL?.absoluteString, "https://img.com/thumb.jpg")
    }

    func testDisplayThumbnailURLFallsBackToImage() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: nil,
            image: "https://img.com/full.jpg"
        )
        XCTAssertEqual(product.displayThumbnailURL?.absoluteString, "https://img.com/full.jpg")
    }

    func testDisplayThumbnailURLFallsBackOnEmptyString() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: "",
            image: "https://img.com/full.jpg"
        )
        XCTAssertEqual(product.displayThumbnailURL?.absoluteString, "https://img.com/full.jpg")
    }

    func testDisplayImageURLPrefersImage() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: "https://img.com/thumb.jpg",
            image: "https://img.com/full.jpg"
        )
        XCTAssertEqual(product.displayImageURL?.absoluteString, "https://img.com/full.jpg")
    }

    func testDisplayImageURLFallsBackToThumbnail() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: "https://img.com/thumb.jpg",
            image: nil
        )
        XCTAssertEqual(product.displayImageURL?.absoluteString, "https://img.com/thumb.jpg")
    }

    func testIsDisplayableReturnsFalseWhenBothURLsNil() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: nil, image: nil
        )
        XCTAssertFalse(product.isDisplayable)
    }

    func testIsDisplayableReturnsFalseWhenBothURLsEmpty() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: "", image: ""
        )
        XCTAssertFalse(product.isDisplayable)
    }

    func testIsDisplayableReturnsTrueWithOneValidURL() {
        let product = Product(
            team: 1, title: "Test", description: nil,
            thumbnail: nil, image: "https://img.com/full.jpg"
        )
        XCTAssertTrue(product.isDisplayable)
    }
}

final class ProductsResponseTests: XCTestCase {

    func testFiltersNullProducts() throws {
        let json = """
        {"products": [{"team": 1, "title": "Valid", "thumbnail": "https://img.com/t.jpg"}, null]}
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ProductsResponse.self, from: json)
        XCTAssertEqual(response.products.count, 2)
        XCTAssertEqual(response.displayableProducts.count, 1)
        XCTAssertEqual(response.displayableProducts[0].title, "Valid")
    }

    func testFiltersNonDisplayableProducts() throws {
        let json = """
        {"products": [
            {"team": 1, "title": "Has Image", "thumbnail": "https://img.com/t.jpg"},
            {"team": 2, "title": "No Image", "thumbnail": null, "image": null},
            {"team": 1, "title": "Empty Image", "thumbnail": "", "image": ""}
        ]}
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ProductsResponse.self, from: json)
        XCTAssertEqual(response.displayableProducts.count, 1)
        XCTAssertEqual(response.displayableProducts[0].title, "Has Image")
    }
}
