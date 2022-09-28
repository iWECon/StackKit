import UIKit

class SpacerLayer: CALayer, _Spacer {
    var length: CGFloat = .greatestFiniteMagnitude
    var min: CGFloat = .leastNonzeroMagnitude
    var max: CGFloat = .greatestFiniteMagnitude
    
    var setLength: CGFloat = 0
    
    required init(length: CGFloat, min: CGFloat, max: CGFloat) {
        super.init()
        
        self.length = length
        self.min = min
        self.max = max
        
        self.backgroundColor = UIColor.clear.cgColor
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 自定义长度范围
    var isCustomRange: Bool {
        (min != .leastNonzeroMagnitude || max != .greatestFiniteMagnitude) && length == .greatestFiniteMagnitude
    }
    // 自定义固定长度
    var isDefine: Bool {
        length != .greatestFiniteMagnitude
    }
    
    enum Size {
        case width, height
    }
    func fitSize(value: CGFloat, for size: Size) {
        var length: CGFloat = 0
        if isDefine {
            length = self.length
        } else if isCustomRange {
            length = Swift.max(Swift.min(value, max), min)
        } else {
            length = value
        }
        length = Swift.max(0, length)
        
        switch size {
        case .width:
            frame.size.width = length
        case .height:
            frame.size.height = length
        }
        self.setLength = Swift.max(0, length)
    }
    
    var minLength: CGFloat {
        if setLength != 0 {
            return setLength
        }
        if length != .greatestFiniteMagnitude {
            return length
        }
        if max != .greatestFiniteMagnitude {
            return max
        }
        if min != .leastNonzeroMagnitude {
            return min
        }
        return 0
    }
}

extension SpacerView {
    var spacerLayer: SpacerLayer {
        SpacerLayer(length: length, min: min, max: max)
    }
}
