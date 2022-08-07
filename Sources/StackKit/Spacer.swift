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
}

public protocol _StackKitViewSpacerResultBuilder {
    static func buildExpression(_ expression: Spacer) -> [UIView]
}
extension _StackKitViewSpacerResultBuilder {
    public static func buildExpression(_ expression: Spacer) -> [UIView] {
        let spacer = SpacerView(length: expression.length, min: expression.min, max: expression.max)
        return [spacer]
    }
}

extension _StackKitHStackContentResultBuilder: _StackKitViewSpacerResultBuilder { }
extension _StackKitVStackContentResultBuilder: _StackKitViewSpacerResultBuilder { }


/**
 HStack(distribution: .spacing(8)) {
    View1()
    Spacer()
    View2()
 }
 
 | view1 | --spacer-- | view2 | // spacing 8 is ignore
 
 HStack(distribution: .spacing(8)) {
    View1()
    Spacer()
    View2()
    View3()
 }
 
 | view1 | --spacer -- | view2 | view3 | // spacing 8 only effective between view2 and view3
 
 HStack(distribution: .spacing(8)) {
    Spacer()
    View1()
    Spacer() // When two or more Spacers are connected together, only the first one will take effect.
    Spacer() // will be ignore
    View2()
    View3()
    Spacer()
 }
 
 | --spacer-- | view1 | --spacer-- | view2 | view3 | --spacer-- |
 // spacer width?
 // (frame.width - (view1 + view2 + view2 + view1~view2.spacing + view2~view3.spacing).width) / spacers.count = spacer.width
 
 // 320
 // 50 * 3 + 8 * 2
 // 320 - (50*3+8*2) = 154
 // 154 / 3
 */

//extension _StackKitHStackContentResultBuilder: _StackKitViewSpacerResultBuilder {
//    public static func buildExpression(_ expression: Spacer) -> [UIView] {
//        let view = SpacerView()
//        view.maxLength = expression.maxLength
//        view.frame.size.height = 1
//        return [view]
//    }
//}
//
//extension _StackKitVStackContentResultBuilder: _StackKitViewSpacerResultBuilder {
//
//    public static func buildExpression(_ expression: Spacer) -> [UIView] {
//        let view = SpacerView()
//        view.maxLength = expression.maxLength
//        view.frame.size.width = 1
//        return [view]
//    }
//}
