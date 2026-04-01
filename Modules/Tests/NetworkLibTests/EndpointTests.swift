import XCTest
import Foundation
@testable import NetworkLib

final class EndpointTests: XCTestCase {

    struct TestEndpoint: Endpoint {
        var baseURL: String = "https://example.com"
        var path: String = "/api/items"
        var method: HTTPMethod = .get
        var headers: [String: String]? = nil
        var queryParams: [String: String]? = nil
        var body: Data? = nil
    }

    func testURLIsConstructedFromBaseURLAndPath() {
        let endpoint = TestEndpoint()
        XCTAssertEqual(endpoint.url?.absoluteString, "https://example.com/api/items")
    }

    func testURLIncludesQueryParameters() {
        var endpoint = TestEndpoint()
        endpoint.queryParams = ["page": "1", "limit": "10"]

        let url = endpoint.url
        XCTAssertNotNil(url)
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "page", value: "1")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "limit", value: "10")))
    }

    func testURLRequestHasCorrectHTTPMethod() {
        var endpoint = TestEndpoint()
        endpoint.method = .post
        XCTAssertEqual(endpoint.urlRequest?.httpMethod, "POST")
    }

    func testURLRequestIncludesHeaders() {
        var endpoint = TestEndpoint()
        endpoint.headers = ["Authorization": "Bearer token"]

        let request = endpoint.urlRequest
        XCTAssertEqual(request?.allHTTPHeaderFields?["Authorization"], "Bearer token")
    }

    func testURLRequestIncludesBody() {
        var endpoint = TestEndpoint()
        endpoint.body = "test".data(using: .utf8)
        XCTAssertEqual(endpoint.urlRequest?.httpBody, "test".data(using: .utf8))
    }

    func testDefaultOptionalPropertiesAreNil() {
        struct MinimalEndpoint: Endpoint {
            var baseURL: String { "https://example.com" }
            var path: String { "/test" }
            var method: HTTPMethod { .get }
        }

        let endpoint = MinimalEndpoint()
        XCTAssertNil(endpoint.headers)
        XCTAssertNil(endpoint.queryParams)
        XCTAssertNil(endpoint.body)
    }
}
