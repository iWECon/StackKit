import UIKit

/// Specific implementation of `Divider` in H/VStackView
class DividerView: UIView, _Divider {
    
    var maxLength: CGFloat = .greatestFiniteMagnitude
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
