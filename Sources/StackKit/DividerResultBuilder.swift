import UIKit

// MARK: - For *StackView
public protocol _StackKitViewDividerResultBuilder {
    static func buildExpression(_ expression: Divider) -> [UIView]
}

// MARK: For HStack
extension _StackKitHStackContentResultBuilder: _StackKitViewDividerResultBuilder {
    public static func buildExpression(_ expression: Divider) -> [UIView] {
        let view = DividerView()
        view.maxLength = expression.maxLength
        view.frame.size.width = expression.thickness
        view.backgroundColor = expression.color
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
        view.backgroundColor = expression.color
        view.layer.cornerRadius = expression.cornerRadius
        return [view]
    }
}


// MARK: - For *StackLayerWrapperView
public protocol _StackKitLayerDividerResultBuilder {
    static func buildExpression(_ expression: Divider) -> [CALayer]
}
extension _StackKitHStackLayerContentResultBuilder: _StackKitLayerDividerResultBuilder {
    public static func buildExpression(_ expression: Divider) -> [CALayer] {
        let layer = DividerLayer()
        layer.maxLength = expression.maxLength
        layer.frame.size.width = expression.thickness
        layer.backgroundColor = expression.color.cgColor
        layer.cornerRadius = expression.cornerRadius
        return [layer]
    }
}

extension _StackKitVStackLayerContentResultBuilder: _StackKitLayerDividerResultBuilder {
    public static func buildExpression(_ expression: Divider) -> [CALayer] {
        let layer = DividerLayer()
        layer.maxLength = expression.maxLength
        layer.frame.size.height = expression.thickness
        layer.backgroundColor = expression.color.cgColor
        layer.cornerRadius = expression.cornerRadius
        return [layer]
    }
}
