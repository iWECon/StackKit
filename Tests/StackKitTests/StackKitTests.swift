import XCTest
@testable import StackKit

final class StackKitTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let label = UILabel().fitSize(with: .size(CGSize(width: 100, height: 22)))
        label.text = "hello world"
        let h = HStackView {
            label
        }.sizeToFit()
        print(label.frame)
        print(label.frame.width < 100)
    }
}
