import UIKit

/// In `HStackView` and `VStackView` will ignore `spacing`
///
/// ⚠️ Multiple spacers used in a row are only valid for the first one.
public struct Spacer: _Spacer {
    public var length: CGFloat
    public var min: CGFloat
    public var max: CGFloat
    
    public init(length: CGFloat = .greatestFiniteMagnitude , min: CGFloat = .leastNonzeroMagnitude, max: CGFloat = .greatestFiniteMagnitude) {
        self.length = length
        self.min = min
        self.max = max
    }
}
