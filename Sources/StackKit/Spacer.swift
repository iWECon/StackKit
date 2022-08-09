import UIKit

public protocol _Spacer {
    var length: CGFloat { get set }
    var min: CGFloat { get set }
    var max: CGFloat { get set }
}

/// In `HStackView` and `VStackView` will ignore `spacing`
///
/// Multiple spacers used in a row are only valid for the first one.
/// 多个连续的 Spacer 在一起时，只有第一个会生效:
/// view.addSubview(view), view.addSubview(spacer), view.addSubview(spacer2).
/// spacer 生效, spacer2 会被忽略.
///
/// ⚠️⚠️⚠️ Don't use in `WrapStackView`, but can use in `HStackView` of `VStackView` of WrapStackView.
public struct Spacer: _Spacer {
    public var length: CGFloat
    public var min: CGFloat
    public var max: CGFloat
    
    public init(length: CGFloat = .greatestFiniteMagnitude , min: CGFloat = .leastNonzeroMagnitude, max: CGFloat = .greatestFiniteMagnitude) {
        self.length = length
        self.min = min
        self.max = max
    }
}

/// Only available in `FreeStackView`
class SpacerView: UIView, _Spacer {
    var length: CGFloat = .greatestFiniteMagnitude
    var min: CGFloat = .leastNonzeroMagnitude
    var max: CGFloat = .greatestFiniteMagnitude
    
    var setLength: CGFloat = -1
    
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
            frame.size.width = length
        case .height:
            frame.size.height = length
        }
        self.setLength = length
    }
    
    var minLength: CGFloat {
        if setLength != -1 {
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
    
    var spacerLayer: SpacerLayer {
        SpacerLayer(length: length, min: min, max: max)
    }
}


class SpacerLayer: CALayer, _Spacer {
    var length: CGFloat = .greatestFiniteMagnitude
    var min: CGFloat = .leastNonzeroMagnitude
    var max: CGFloat = .greatestFiniteMagnitude
    
    var setLength: CGFloat = -1
    
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
            frame.size.width = length
        case .height:
            frame.size.height = length
        }
        self.setLength = length
    }
    
    var minLength: CGFloat {
        if setLength != -1 {
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
