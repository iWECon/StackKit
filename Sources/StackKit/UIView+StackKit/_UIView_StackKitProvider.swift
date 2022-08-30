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
