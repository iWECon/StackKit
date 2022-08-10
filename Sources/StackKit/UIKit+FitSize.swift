import UIKit

var _FitTypeKey = "_FitTypeKey"

public enum FitType {
    /// Just only call `.sizeToFit()`.
    case content
    
    /// The width fixed.
    case widthFixed(_ value: CGFloat)
    /// The height fixed.
    case heightFixed(_ value: CGFloat)
    
    /// The width flexible.
    case widthFlexible(_ value: CGFloat? = nil, min: CGFloat? = nil, max: CGFloat? = nil)
    
    /// The height flexible.
    case heightFlexible(_ value: CGFloat? = nil, min: CGFloat? = nil, max: CGFloat? = nil)
    
    case size(_ size: CGSize)
}

protocol FitSize {
    var stackKitFitType: FitType { get set }
    func _fitSize(with fitType: FitType)
}

extension UIView: FitSize {
    
    public internal(set) var stackKitFitType: FitType {
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
    
    public func fitSize(with fitType: FitType) -> Self {
        self.stackKitFitType = fitType
        return self
    }
    
    func _fitSize(with fitType: FitType = .content) {
        
        defer {
            setNeedsLayout()
        }
        
        switch fitType {
        case .content:
            sizeToFit()
            
        case .widthFixed(let value):
            let size = CGSize(
                width: value,
                height: CGFloat.greatestFiniteMagnitude
            )
            var fitSize = sizeThatFits(size)
            fitSize.width = value
            self.frame.size = fitSize
            
        case .heightFixed(let value):
            let size = CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: value
            )
            var fitSize = sizeThatFits(size)
            fitSize.height = value
            self.frame.size = fitSize
            
        case .widthFlexible(let value, let minWidth, let maxWidth):
            var fitWidth: CGFloat = superSize()?.width ?? .greatestFiniteMagnitude
            if let value = value {
                fitWidth = value
            }
            if let minWidth = minWidth, minWidth > fitWidth {
                fitWidth = minWidth
            }
            if let maxWidth = maxWidth, maxWidth < fitWidth {
                fitWidth = maxWidth
            }
            let size = CGSize(
                width: fitWidth,
                height: CGFloat.greatestFiniteMagnitude
            )
            var newSize = sizeThatFits(size)
            if let minWidth = minWidth, minWidth > newSize.width {
                newSize.width = minWidth
            }
            if let maxWidth = maxWidth, maxWidth < newSize.width {
                newSize.width = maxWidth
            }
            self.frame.size = newSize
            
        case .heightFlexible(let value, let minHeight, let maxHeight):
            var fitHeight: CGFloat = superSize()?.height ?? .greatestFiniteMagnitude
            if let value = value {
                fitHeight = value
            }
            if let minHeight = minHeight, minHeight > fitHeight {
                fitHeight = minHeight
            }
            if let maxHeight = maxHeight, maxHeight < fitHeight {
                fitHeight = maxHeight
            }
            let size = CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: fitHeight
            )
            var newSize = sizeThatFits(size)
            if let minHeight = minHeight, minHeight > newSize.height {
                newSize.height = minHeight
            }
            if let maxHeight = maxHeight, maxHeight < newSize.height {
                newSize.height = maxHeight
            }
            self.frame.size = newSize
            
        case .size(let size):
            self.frame.size = size
        }
    }
    
    private func superSize() -> CGSize? {
        var spv = superview
        while spv != nil {
            if spv?.frame.size == .zero {
                spv = spv?.superview
                continue
            }
            break
        }
        return spv?.frame.size
    }
}
