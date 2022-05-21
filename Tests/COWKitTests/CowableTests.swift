import XCTest

@testable
import COWKit

final class CowableTests: XCTestCase {

    func testCowableWrappedValueHornersValueSemantics() throws {
        @Cowable
        var value1 = 0

        @Cowable($value1)
        var value2: Int

        value1 = 10

        XCTAssertEqual(value1, 10)
        XCTAssertEqual(value2, 0)
    }

}
