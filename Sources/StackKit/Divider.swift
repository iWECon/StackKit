import UIKit

public protocol _Divider {
    var thickness: CGFloat { get }
    var maxLength: CGFloat { get set }
    var color: UIColor { get }
    var cornerRadius: CGFloat { get }
}
extension _Divider {
    public var thickness: CGFloat { 1 }
    public var color: UIColor { .gray }
    public var cornerRadius: CGFloat { 0 }
}

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
        backgroundColor: UIColor = .gray,
        cornerRadius: CGFloat = 0
    ) {
        self.thickness = thickness
        self.maxLength = maxLength
        self.color = backgroundColor
        self.cornerRadius = cornerRadius
    }
}

class DividerView: UIView, _Divider {
    
    var maxLength: CGFloat = .greatestFiniteMagnitude
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DividerLayer: CALayer, _Divider {
    var maxLength: CGFloat = .greatestFiniteMagnitude
    
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
