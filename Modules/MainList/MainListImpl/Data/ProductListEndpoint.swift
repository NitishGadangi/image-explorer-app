import Foundation
import NetworkLib

struct ProductListEndpoint: Endpoint {
    var baseURL: String { "https://raw.githubusercontent.com" }
    var path: String { "/PaulLavoine/iOS_technical_test/main/inteview_test.json" }
    var method: HTTPMethod { .get }
}
