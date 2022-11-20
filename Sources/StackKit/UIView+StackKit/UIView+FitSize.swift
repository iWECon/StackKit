import UIKit

var _StackKit_FitTypeKey = "_StackKit_FitTypeKey"

public enum FitType {
    case content
    
    /// **Adjust the view’s height** based on the reference width.
    case width
    
    /// **Adjust the view’s width** based on the reference height.
    case height
    
    case widthFlexible
    case heightFlexible
    
    var isFlexible: Bool {
        if case .widthFlexible = self {
            return true
        } else if case .heightFlexible = self {
            return true
        }
        return false
    }
}

protocol FitSize {
    var _stackKit_fitType: FitType { get set }
    func _fitSize(with fitType: FitType)
}

extension UIView: FitSize {
    
    var _stackKit_fitType: FitType {
        get {
            guard let fitType = objc_getAssociatedObject(self, &_StackKit_FitTypeKey) as? FitType else {
                return .content
            }
            return fitType
        }
        set {
            objc_setAssociatedObject(self, &_StackKit_FitTypeKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    func fitSize(with fitType: FitType) -> Self {
        self._stackKit_fitType = fitType
        return self
    }
    
    func _fitSize(with fitType: FitType) {
        
        defer {
            setNeedsLayout()
        }
        
        var size = resolveSize()
        
        if let w = size.width, let h = size.height { // 指定了 size（width & height) 优先使用 size
            let _ = sizeThatFits(.zero)
            self.frame.size = CGSize(width: w, height: h)
            return
        }
        
        var fitWidth = CGFloat.greatestFiniteMagnitude
        var fitHeight = CGFloat.greatestFiniteMagnitude
        
        switch fitType {
        case .width, .widthFlexible:
            if let w = applyMinMax(toWidth: size.width) {
                fitWidth = w
            } else {
                fitWidth = bounds.width
            }
            
        case .height, .heightFlexible:
            if let h = applyMinMax(toHeight: size.height) {
                fitHeight = h
            } else {
                fitHeight = bounds.height
            }
            
        case .content:
            fitWidth = size.width ?? _stackKit_maxWidth ?? bounds.width
            fitHeight = size.height ?? _stackKit_maxHeight ?? bounds.height
        }
        
        fitWidth = _validateValue(fitWidth)
        fitHeight = _validateValue(fitHeight)
        
        let sizeThatFits = sizeThatFits(CGSize(width: fitWidth, height: fitHeight))
        
        switch fitType {
        case .width, .height:
            if fitWidth != .greatestFiniteMagnitude {
                size.width = fitWidth
            } else {
                size.width = sizeThatFits.width
            }
            
            if fitHeight != .greatestFiniteMagnitude {
                size.height = fitHeight
            } else {
                size.height = sizeThatFits.height
            }
            
        case .widthFlexible:
            size.height = fitHeight
            size.width = sizeThatFits.width
            
        case .heightFlexible:
            size.height = fitType.isFlexible ? sizeThatFits.height : fitHeight
            size.width = fitWidth
            
        case .content:
            size = Size(width: sizeThatFits.width, height: sizeThatFits.height)
        }
        
        // fix when set single width or height not working
        _fixedSize(&size)
        
        size.width = applyMinMax(toWidth: size.width)
        size.height = applyMinMax(toHeight: size.height)
        
        self.frame.size = size.cgSize
    }
    
    private func _validateValue(_ value: CGFloat?) -> CGFloat {
        guard let value = value, value > 0, value.isFinite else {
            return .greatestFiniteMagnitude
        }
        return value
    }
    
    private func _fixedSize(_ size: inout Size) {
        if let w = _stackKit_width {
            size.width = w
        }
        if let h = _stackKit_height {
            size.height = h
        }
    }
}

extension UIView {
    
    struct Size {
        var width: CGFloat?
        var height: CGFloat?
        
        var cgSize: CGSize {
            CGSize(width: width ?? 0, height: height ?? 0)
        }
    }
    
    func resolveSize() -> Size {
        var size = Size()
        if let _width = _stackKit_width {
            size.width = _width
        }
        if let _height = _stackKit_height {
            size.height = _height
        }
        return size
    }
    
    func applyMinMax(toWidth width: CGFloat?) -> CGFloat? {
        var result = width
        
        // Handle minWidth
        if let minWidth = _stackKit_minWidth, minWidth > (result ?? 0) {
            result = minWidth
        }
        
        // Handle maxWidth
        if let maxWidth = _stackKit_maxWidth, maxWidth < (result ?? CGFloat.greatestFiniteMagnitude) {
            result = maxWidth
        }
        return result
    }
    
    func applyMinMax(toHeight height: CGFloat?) -> CGFloat? {
        var result = height
        
        // Handle minWidth
        if let minWidth = _stackKit_minHeight, minWidth > (result ?? 0) {
            result = minWidth
        }
        
        // Handle maxWidth
        if let maxWidth = _stackKit_maxHeight, maxWidth < (result ?? CGFloat.greatestFiniteMagnitude) {
            result = maxWidth
        }
        
        return result
    }
    
}
