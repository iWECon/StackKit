import UIKit

var _FitTypeKey = "_FitTypeKey"

public enum FitType {
    case content
    
    case width
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
    var stackKitFitType: FitType { get set }
    func _fitSize(with fitType: FitType)
}

extension UIView: FitSize {
    
    var stackKitFitType: FitType {
        get {
            guard let fitType = objc_getAssociatedObject(self, &_FitTypeKey) as? FitType else {
                return .content
            }
            return fitType
        }
        set {
            objc_setAssociatedObject(self, &_FitTypeKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    func fitSize(with fitType: FitType) -> Self {
        self.stackKitFitType = fitType
        return self
    }
    
    func _fitSize(with fitType: FitType = .content) {
        
        defer {
            setNeedsLayout()
        }
        
        if fitType == .content, let w = _width, let h = _height {
            self.frame.size = CGSize(width: w, height: h)
            return
        }
        
        // 优先从设定的 width 和 height 获取
        var fitWidth = _width ?? CGFloat.greatestFiniteMagnitude
        var fitHeight = _height ?? CGFloat.greatestFiniteMagnitude
        var size = resolveSize()
        
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
            let fs = bounds.size
            fitWidth = size.width ?? fs.width
            fitHeight = size.height ?? fs.width
        }
        
        fitWidth = _validateValue(fitWidth)
        fitHeight = _validateValue(fitHeight)
        
        let sizeThatFits = sizeThatFits(CGSize(width: fitWidth, height: fitHeight))
        
        switch fitType {
        case .content:
            size = Size(width: sizeThatFits.width, height: sizeThatFits.height)
            _fixedSize(&size)
            
        case .width, .widthFlexible, .height, .heightFlexible:
            if fitWidth != .greatestFiniteMagnitude {
                size.width = fitType.isFlexible ? sizeThatFits.width : fitWidth
            } else {
                size.width = sizeThatFits.width
            }
            
            if fitHeight != .greatestFiniteMagnitude {
                size.height = fitType.isFlexible ? sizeThatFits.height : fitHeight
            } else {
                size.height = sizeThatFits.height
            }
        }
        
        size.width = applyMinMax(toWidth: size.width)
        size.height = applyMinMax(toHeight: size.height)
        _fixedSize(&size)
        
        if let w = size.width, let h = size.height {
            self.bounds.size = CGSize(width: w, height: h)
        } else {
            fatalError("Size has some error.")
        }
    }
    
    private func _validateValue(_ value: CGFloat?) -> CGFloat {
        guard let value = value, value > 0, value.isFinite else {
            return .greatestFiniteMagnitude
        }
        return value
    }
    
    private func _fixedSize(_ size: inout Size) {
        if let w = _width {
            size.width = w
        }
        if let h = _height {
            size.height = h
        }
    }
}

extension UIView {
    
    struct Size {
        var width: CGFloat?
        var height: CGFloat?
    }
    
    func resolveSize() -> Size {
        var size = Size()
        if let _width = _width {
            size.width = _width
        }
        if let _height = _height {
            size.height = _height
        }
        return size
    }
    
    func applyMinMax(toWidth width: CGFloat?) -> CGFloat? {
        var result = width
        
        // Handle minWidth
        if let minWidth = _minWidth, minWidth > (result ?? 0) {
            result = minWidth
        }
        
        // Handle maxWidth
        if let maxWidth = _maxWidth, maxWidth < (result ?? CGFloat.greatestFiniteMagnitude) {
            result = maxWidth
        }
        return result
    }
    
    func applyMinMax(toHeight height: CGFloat?) -> CGFloat? {
        var result = height
        
        // Handle minWidth
        if let minWidth = _minHeight, minWidth > (result ?? 0) {
            result = minWidth
        }
        
        // Handle maxWidth
        if let maxWidth = _maxHeight, maxWidth < (result ?? CGFloat.greatestFiniteMagnitude) {
            result = maxWidth
        }
        
        return result
    }
    
}
