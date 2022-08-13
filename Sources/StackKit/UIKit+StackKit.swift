import UIKit

struct _UIView_StackKitKeys {
    static var widthKey = "StackKit_widthKey"
    static var heightKey = "StackKit_heightKey"
    
    static var minWidthKey = "StackKit_minWidthKey"
    static var maxWidthKey = "StackKit_maxWidthKey"
    
    static var minHeightKey = "StackKit_minHeightKey"
    static var maxHeightKey = "StackKit_maxHeightKey"
}

protocol _UIView_StackKitProvider {
    var _width: CGFloat? { get set }
    var _height: CGFloat? { get set }
    
    var _minWidth: CGFloat? { get set }
    var _maxWidth: CGFloat? { get set }
    
    var _minHeight: CGFloat? { get set }
    var _maxHeight: CGFloat? { get set }
}

extension UIView: _UIView_StackKitProvider {
    var _width: CGFloat? {
        get {
            guard let value = Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.widthKey) else {
                return nil
            }
            return value
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.widthKey, newValue)
        }
    }
    var _height: CGFloat? {
        get {
            guard let value = Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.heightKey) else {
                return nil
            }
            return value
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.heightKey, newValue)
        }
    }
    var _minWidth: CGFloat? {
        get {
            guard let value = Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.minWidthKey) else {
                return nil
            }
            return value
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.minWidthKey, newValue)
        }
    }
    
    var _maxWidth: CGFloat? {
        get {
            guard let value = Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.maxWidthKey) else {
                return nil
            }
            return value
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.maxWidthKey, newValue)
        }
    }
    
    var _minHeight: CGFloat? {
        get {
            guard let value = Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.minHeightKey) else {
                return nil
            }
            return value
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.minHeightKey, newValue)
        }
    }
    
    var _maxHeight: CGFloat? {
        get {
            guard let value = Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.maxHeightKey) else {
                return nil
            }
            return value
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.maxHeightKey, newValue)
        }
    }
}

public class StackKitCompatible<Base> {
    let view: Base
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
