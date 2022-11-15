import XCTest
@testable import StackKit

final class StackKitTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let label = UILabel()
        let container = VStackView(alignment: .center, distribution: .spacing(2), padding: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)) {
            label.stack.then {
                $0.text = "你好啊"
            }
        }
        let v = VStackView(alignment: .center, distribution: .fillWidth(spacing: 0), padding: .zero) {
            container.stack.height(50)
        }
        
        v.layoutSubviews()
        print(label.frame.size)
        print(container.frame.size)
        XCTAssertEqual(label.frame.minY, (container.frame.height - label.frame.height) / 2)
    }
}
