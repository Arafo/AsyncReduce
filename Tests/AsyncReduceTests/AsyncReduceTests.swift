import XCTest
@testable import AsyncReduce

final class ReduceTests: TestCase {
    func testNonThrowingAsyncReduce() {
        runAsyncTest { array, collector in
            _ = await array.asyncReduce([Int](), { result, element in
                var result = result
                result.append(await collector.collectAndReturn(element))
                return result
            })
            XCTAssertEqual(collector.values, array)
        }
    }

    func testThrowingAsyncReduceThatDoesNotThrow() {
        runAsyncTest { array, collector in
            _ = try await array.asyncReduce([Int](), { result, element in
                var result = result
                result.append(try await collector.tryCollectAndReturn(element))
                return result
            })
            XCTAssertEqual(collector.values, array)
        }
    }

    func testThrowingAsyncForEachThatThrows() {
        runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.asyncReduce([Int](), { result, element in
                    var result = result
                    result.append(
                        try await collector.tryCollectAndReturn(
                            element,
                            throwError: element == 3 ? error : nil
                        )
                    )
                    return result
                })
            }
            XCTAssertEqual(collector.values, [0, 1, 2])
        }
    }
}
