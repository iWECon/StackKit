import UIKit

///
/// In `HStackView` the divier is `vertical` line: |
/// In `VStackView` the divier is `horizontal` line: ---
///
/// 在 `HStackView` 中以竖线显示
/// 在 `VStackView` 中以横线显示
///
public struct Divider: _Divider {
    public var thickness: CGFloat = 1
    public var maxLength: CGFloat = CGFloat.greatestFiniteMagnitude
    public var color: UIColor = .gray
    public var cornerRadius: CGFloat = 0
    
    public init(
        thickness: CGFloat = 1,
        maxLength: CGFloat = CGFloat.greatestFiniteMagnitude,
        color: UIColor = .gray,
        cornerRadius: CGFloat = 0
    ) {
        self.thickness = thickness
        self.maxLength = maxLength
        self.color = color
        self.cornerRadius = cornerRadius
    }
}
