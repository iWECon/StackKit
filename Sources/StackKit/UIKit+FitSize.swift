import UIKit

var _FitTypeKey = "_FitTypeKey"

public enum FitType {
    case content
    
    case widthFixed(_ value: CGFloat)
    case heightFixed(_ value: CGFloat)
    
    case widthFlexible(_ value: CGFloat)
    case heightFlexible(_ value: CGFloat)
    
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
            objc_setAssociatedObject(self, &_FitTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func fitSize(with fitType: FitType) -> Self {
        self.stackKitFitType = fitType
        return self
    }
    
    func _fitSize(with fitType: FitType = .content) {
        
        defer {
            layoutSubviews()
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
            
        case .widthFlexible(let value):
            let size = CGSize(
                width: value,
                height: CGFloat.greatestFiniteMagnitude
            )
            self.frame.size = sizeThatFits(size)
            
        case .heightFlexible(let value):
            let size = CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: value
            )
            self.frame.size = sizeThatFits(size)
            
        case .size(let size):
            self.frame.size = size
        }
    }
}
