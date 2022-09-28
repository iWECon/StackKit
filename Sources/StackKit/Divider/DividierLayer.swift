import UIKit

class DividerLayer: CALayer, _Divider {
    var maxLength: CGFloat = .greatestFiniteMagnitude
    
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

