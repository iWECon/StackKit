import UIKit

@resultBuilder
public struct _StackKitLayerContentResultBuilder {
    public static func buildBlock(_ components: [CALayer]...) -> [CALayer] {
        components.flatMap({ $0 })
    }
    public static func buildOptional(_ component: [CALayer]?) -> [CALayer] {
        component ?? []
    }
    public static func buildExpression(_ expression: CALayer) -> [CALayer] {
        [expression]
    }
    public static func buildEither(first component: [CALayer]) -> [CALayer] {
        component
    }
    public static func buildEither(second component: [CALayer]) -> [CALayer] {
        component
    }
    public static func buildExpression(_ expression: Void) -> [CALayer] {
        []
    }
}

public protocol _StackKitViewContentResultBuilderProvider { }
extension _StackKitViewContentResultBuilderProvider {
    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap({ $0 })
    }
    public static func buildOptional(_ component: [UIView]?) -> [UIView] {
        component ?? []
    }
    public static func buildExpression(_ expression: UIView) -> [UIView] {
        [expression]
    }
    public static func buildEither(first component: [UIView]) -> [UIView] {
        component
    }
    public static func buildEither(second component: [UIView]) -> [UIView] {
        component
    }
    public static func buildExpression(_ expression: Void) -> [UIView] {
        []
    }
}

// MARK: - For VStack View
@resultBuilder public struct _StackKitVStackContentResultBuilder: _StackKitViewContentResultBuilderProvider { }

// MARK: - For HStack View
@resultBuilder public struct _StackKitHStackContentResultBuilder: _StackKitViewContentResultBuilderProvider { }

// MARK: - For WrapStack View
@resultBuilder public struct _StackKitWrapStackContentResultBuilder: _StackKitViewContentResultBuilderProvider { }

@resultBuilder
public struct _StackKitFreeStackViewContentResultBuilder: _StackKitViewContentResultBuilderProvider { }
