import UIKit

extension UIView {
    
    var _isIneffectiveView: Bool {
        isHidden || alpha <= 0 || (frame.size == .zero && clipsToBounds == true)
    }
    
    var _isEffectiveView: Bool {
        !_isIneffectiveView
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
