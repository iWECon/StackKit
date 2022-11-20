import UIKit

/// Specific implementation of `Spacer` in H/VStackView
class SpacerView: UIView, _Spacer {
    var length: CGFloat = .greatestFiniteMagnitude
    var min: CGFloat = .leastNonzeroMagnitude
    var max: CGFloat = .greatestFiniteMagnitude
    
    var setLength: CGFloat = 0
    
    required init(length: CGFloat, min: CGFloat, max: CGFloat) {
        super.init(frame: .zero)
        
        self.length = length
        self.min = min
        self.max = max
        
        backgroundColor = .clear
        isUserInteractionEnabled = false
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
        let length: CGFloat
        if isDefine {
            length = self.length
        } else if isCustomRange {
            length = Swift.max(Swift.min(value, max), min)
        } else {
            length = value
        }
        
        switch size {
        case .width:
            frame.size.width = Swift.max(0, length)
        case .height:
            frame.size.height = Swift.max(0, length)
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

