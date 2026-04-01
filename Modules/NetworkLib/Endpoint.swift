import Foundation

public protocol Endpoint: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParams: [String: String]? { get }
    var body: Data? { get }
}

public extension Endpoint {
    var headers: [String: String]? { nil }
    var queryParams: [String: String]? { nil }
    var body: Data? { nil }

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        if let queryParams {
            components?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        return components?.url
    }

    var urlRequest: URLRequest? {
        guard let url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        return request
    }
}
