import UIKit

public protocol _Divider {
    var thickness: CGFloat { get }
    var maxLength: CGFloat { get set }
    var backgroundColor: UIColor { get }
    var cornerRadius: CGFloat { get }
}
extension _Divider {
    public var thickness: CGFloat { 1 }
    public var backgroundColor: UIColor { .gray }
    public var cornerRadius: CGFloat { 0 }
}

/// In HStack the divier is vertical line
/// In VStack the divier is horizontal line
public struct Divider: _Divider {
    public var thickness: CGFloat = 1
    public var maxLength: CGFloat = CGFloat.greatestFiniteMagnitude
    public var backgroundColor: UIColor = .gray
    public var cornerRadius: CGFloat = 0
    
    public init(
        thickness: CGFloat = 1,
        maxLength: CGFloat = CGFloat.greatestFiniteMagnitude,
        backgroundColor: UIColor = .gray,
        cornerRadius: CGFloat = 0
    ) {
        self.thickness = thickness
        self.maxLength = maxLength
        self.backgroundColor = backgroundColor
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

public protocol _StackKitViewDividerResultBuilder {
    static func buildExpression(_ expression: Divider) -> [UIView]
}

// MARK: For HStack
extension _StackKitHStackContentResultBuilder: _StackKitViewDividerResultBuilder {
    public static func buildExpression(_ expression: Divider) -> [UIView] {
        let view = DividerView()
        view.maxLength = expression.maxLength
        view.frame.size.width = expression.thickness
        view.backgroundColor = expression.backgroundColor
        view.layer.cornerRadius = expression.cornerRadius
        return [view]
    }
}

// MARK: For VStack
extension _StackKitVStackContentResultBuilder: _StackKitViewDividerResultBuilder {
    public static func buildExpression(_ expression: Divider) -> [UIView] {
        let view = DividerView()
        view.maxLength = expression.maxLength
        view.frame.size.height = expression.thickness
        view.backgroundColor = expression.backgroundColor
        view.layer.cornerRadius = expression.cornerRadius
        return [view]
    }
}
