import Foundation

public final class URLSessionNetworkService: NetworkService, @unchecked Sendable {
    public let configuration: NetworkConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder
    private let retryHandler: RetryHandler

    public init(
        configuration: NetworkConfiguration = NetworkConfiguration(),
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
        self.retryHandler = RetryHandler(
            maxRetries: configuration.maxRetries,
            baseBackoff: configuration.baseBackoff
        )
    }

    public func request<T: Decodable & Sendable>(endpoint: Endpoint) async throws -> T {
        guard var urlRequest = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }
        urlRequest.timeoutInterval = configuration.timeout
        let request = urlRequest

        return try await retryHandler.perform(
            shouldRetry: { Self.isRetryable($0) },
            operation: { try await self.performRequest(request) }
        )
    }

    // MARK: - Private

    private func performRequest<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(
                    NSError(domain: "Invalid response", code: -1)
                )
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.requestFailed(
                    statusCode: httpResponse.statusCode, data: data
                )
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }

        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            switch urlError.code {
            case .timedOut:
                throw NetworkError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternet
            default:
                throw NetworkError.unknown(urlError)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    private static func isRetryable(_ error: Error) -> Bool {
        guard let networkError = error as? NetworkError else { return false }
        switch networkError {
        case .requestFailed(let code, _):
            return (500...599).contains(code)
        case .timeout, .noInternet:
            return true
        default:
            return false
        }
    }
}
