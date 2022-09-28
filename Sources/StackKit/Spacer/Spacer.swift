import UIKit

/// In `HStackView` and `VStackView` will ignore `spacing`
///
/// Multiple spacers used in a row are only valid for the first one.
/// 多个连续的 Spacer 在一起时，只有第一个会生效:
/// view.addSubview(view), view.addSubview(spacer), view.addSubview(spacer2).
/// spacer 生效, spacer2 会被忽略.
///
/// ⚠️⚠️⚠️ Don't use in `WrapStackView`, but can use in `HStackView` of `VStackView` of WrapStackView.
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
