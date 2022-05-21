import XCTest

@testable
import COWKit

final class COWableSequenceTests: XCTestCase {
    
    func testIteratedCowableElementsHornerValueSemantics() throws {
        @Cowable
        var value = [0, 1, 2, 3]

        var all: [Cowable<Int>] = []

        var iterator = $value.makeIterator()

        while let next = iterator.next() {
            all.append(next)
        }

        let copiedAll = all

        all[0].wrappedValue = 3
        all[1].wrappedValue = 2
        all[2].wrappedValue = 1
        all[3].wrappedValue = 0

        XCTAssertEqual(value, [0, 1, 2, 3])

        XCTAssertEqual(all[0].wrappedValue, 3)
        XCTAssertEqual(all[1].wrappedValue, 2)
        XCTAssertEqual(all[2].wrappedValue, 1)
        XCTAssertEqual(all[3].wrappedValue, 0)
        
        XCTAssertEqual(copiedAll[0].wrappedValue, 0)
        XCTAssertEqual(copiedAll[1].wrappedValue, 1)
        XCTAssertEqual(copiedAll[2].wrappedValue, 2)
        XCTAssertEqual(copiedAll[3].wrappedValue, 3)

    }

}
