import XCTest
@testable import NetworkLib

final class RetryHandlerTests: XCTestCase {

    func testSucceedsOnFirstAttempt() async throws {
        let handler = RetryHandler(maxRetries: 3, baseBackoff: 0.01)
        var callCount = 0

        let result: String = try await handler.perform(
            shouldRetry: { _ in true },
            operation: {
                callCount += 1
                return "success"
            }
        )

        XCTAssertEqual(result, "success")
        XCTAssertEqual(callCount, 1)
    }

    func testRetriesThenSucceeds() async throws {
        let handler = RetryHandler(maxRetries: 3, baseBackoff: 0.01)
        var callCount = 0

        let result: String = try await handler.perform(
            shouldRetry: { _ in true },
            operation: {
                callCount += 1
                if callCount < 3 {
                    throw NetworkError.timeout
                }
                return "success"
            }
        )

        XCTAssertEqual(result, "success")
        XCTAssertEqual(callCount, 3)
    }

    func testThrowsImmediatelyForNonRetryableError() async {
        let handler = RetryHandler(maxRetries: 3, baseBackoff: 0.01)
        var callCount = 0

        do {
            let _: String = try await handler.perform(
                shouldRetry: { _ in false },
                operation: {
                    callCount += 1
                    throw NetworkError.invalidURL
                }
            )
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual(callCount, 1)
        }
    }

    func testExhaustsAllRetries() async {
        let handler = RetryHandler(maxRetries: 2, baseBackoff: 0.01)
        var callCount = 0

        do {
            let _: String = try await handler.perform(
                shouldRetry: { _ in true },
                operation: {
                    callCount += 1
                    throw NetworkError.timeout
                }
            )
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual(callCount, 3) // initial + 2 retries
        }
    }

    func testZeroRetriesMeansSingleAttempt() async {
        let handler = RetryHandler(maxRetries: 0, baseBackoff: 0.01)
        var callCount = 0

        do {
            let _: String = try await handler.perform(
                shouldRetry: { _ in true },
                operation: {
                    callCount += 1
                    throw NetworkError.timeout
                }
            )
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual(callCount, 1)
        }
    }
}
