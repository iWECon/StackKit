import UIKit

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
    
    public func width(_ value: CGFloat?) -> Self {
        view._width = value
        return self
    }
    public func height(_ value: CGFloat?) -> Self {
        view._height = value
        return self
    }
    
    public func maxWidth(_ value: CGFloat?) -> Self {
        view._maxWidth = value
        return self
    }
    public func maxHeight(_ value: CGFloat?) -> Self {
        view._maxHeight = value
        return self
    }
    public func minWidth(_ value: CGFloat?) -> Self {
        view._minWidth = value
        return self
    }
    public func minHeight(_ value: CGFloat?) -> Self {
        view._minHeight = value
        return self
    }
    
    public func size(_ length: CGFloat) -> Self {
        view._width = length
        view._height = length
        return self
    }
    
    public func size(_ width: CGFloat, _ height: CGFloat) -> Self {
        view._width = width
        view._height = height
        return self
    }
    
    public func size(_ size: CGSize) -> Self {
        view._width = size.width
        view._height = size.height
        return self
    }
    
    public func sizeToFit(_ fitType: FitType = .content) -> Self {
        view.stackKitFitType = fitType
        return self
    }
    public func then(_ then: (Base) -> Void) -> Self {
        then(self.view)
        return self
    }
}
