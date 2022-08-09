import UIKit

// MARK: - For *StackView
public protocol _StackKitViewSpacerResultBuilder {
    static func buildExpression(_ expression: Spacer) -> [UIView]
}
extension _StackKitViewSpacerResultBuilder {
    public static func buildExpression(_ expression: Spacer) -> [UIView] {
        let spacer = SpacerView(length: expression.length, min: expression.min, max: expression.max)
        return [spacer]
    }
}

extension _StackKitHStackContentResultBuilder: _StackKitViewSpacerResultBuilder { }
extension _StackKitVStackContentResultBuilder: _StackKitViewSpacerResultBuilder { }


// MARK: - For *StackLayer
public protocol _StackKitLayerSpacerResultBuilder {
    static func buildExpression(_ expression: Spacer) -> [CALayer]
}
extension _StackKitLayerSpacerResultBuilder {
    public static func buildExpression(_ expression: Spacer) -> [CALayer] {
        let spacer = SpacerLayer(length: expression.length, min: expression.min, max: expression.max)
        return [spacer]
    }
}
extension _StackKitHStackLayerContentResultBuilder: _StackKitLayerSpacerResultBuilder { }
extension _StackKitVStackLayerContentResultBuilder: _StackKitLayerSpacerResultBuilder { }
