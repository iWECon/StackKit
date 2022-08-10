import UIKit

public class StackKitCompatible<Base> {
    public let view: Base

    init(view: Base) {
        self.view = view
    }
}

public protocol StackKitCompatibleProvider {
    associatedtype O
    var stack: O { get }
    static var stack: O { get }
}

public extension StackKitCompatibleProvider where Self: UIView {
    var stack: StackKitCompatible<Self> {
        return StackKitCompatible(view: self)
    }
    static var stack: StackKitCompatible<Self> {
        return StackKitCompatible(view: Self.init())
    }
}

extension UIView: StackKitCompatibleProvider { }


extension StackKitCompatible where Base: UIView {
    
    func maxWidth() -> Self {
        return self
    }
    func maxHeight() -> Self {
        return self
    }
    func minWidth() -> Self {
        return self
    }
    func minHeight() -> Self {
        return self
    }
    
}
