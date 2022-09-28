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
    var _stackKit_width: CGFloat? { get set }
    var _stackKit_height: CGFloat? { get set }
    
    var _stackKit_minWidth: CGFloat? { get set }
    var _stackKit_maxWidth: CGFloat? { get set }
    
    var _stackKit_minHeight: CGFloat? { get set }
    var _stackKit_maxHeight: CGFloat? { get set }
}

extension UIView: _UIView_StackKitProvider {
    
    var _stackKit_width: CGFloat? {
        get {
            Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.widthKey)
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.widthKey, newValue)
        }
    }
    var _stackKit_height: CGFloat? {
        get {
            Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.heightKey)
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.heightKey, newValue)
        }
    }
    var _stackKit_minWidth: CGFloat? {
        get {
            Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.minWidthKey)
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.minWidthKey, newValue)
        }
    }
    
    var _stackKit_maxWidth: CGFloat? {
        get {
            Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.maxWidthKey)
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.maxWidthKey, newValue)
        }
    }
    
    var _stackKit_minHeight: CGFloat? {
        get {
            Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.minHeightKey)
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.minHeightKey, newValue)
        }
    }
    
    var _stackKit_maxHeight: CGFloat? {
        get {
            Runtime.getCGFloatProperty(self, key: &_UIView_StackKitKeys.maxHeightKey)
        }
        set {
            Runtime.setCGFloatProperty(self, key: &_UIView_StackKitKeys.maxHeightKey, newValue)
        }
    }
}
