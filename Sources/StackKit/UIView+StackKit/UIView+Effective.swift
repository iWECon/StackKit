import UIKit

extension UIView {
    
    var _isIneffectiveView: Bool {
        isHidden || alpha <= 0 || (frame.size == .zero && clipsToBounds == true)
    }
    
    var _isEffectiveView: Bool {
        !_isIneffectiveView
    }
    
    func _tryFixSize() {
        if frame.size == .zero {
            frame.size = intrinsicContentSize
        }
        if frame.size == .zero {
            sizeToFit()
        }
    }
}

extension CALayer {
    
    var _isIneffectiveLayer: Bool {
        isHidden || opacity <= 0 || (frame.size == .zero && masksToBounds == true)
    }
    
    var _isEffectiveLayer: Bool {
        !_isIneffectiveLayer
    }
    
}
