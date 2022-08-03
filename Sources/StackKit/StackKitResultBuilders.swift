import UIKit

@resultBuilder
public struct _StackKitLayerContentResultBuilder {
    public static func buildBlock(_ components: CALayer...) -> [CALayer] {
        components
    }
}

@resultBuilder
public struct _StackKitViewContentResultBuilder {
    public static func buildBlock(_ components: UIView...) -> [UIView] {
        components
    }
}
