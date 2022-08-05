import UIKit

public protocol _Spacer {
    var min: CGFloat { get set }
    var max: CGFloat { get set }
}

/// In `HStackView` will ignore `spacing`, but can't effect when distribution value is `.fill`
/// In `VStackView` will ignore `spacing`, but can't effect when distribution value is `.fill`
///
/// Multiple spacers used in a row are only valid for the first one.
///
/// ⚠️⚠️⚠️ Don't use in `WrapStackView`, but can use in `HStackView` of `VStackView` of WrapStackView.
public struct Spacer: _Spacer {
    public var min: CGFloat = .leastNonzeroMagnitude
    public var max: CGFloat = .greatestFiniteMagnitude
    
    public init(min: CGFloat = .leastNonzeroMagnitude, max: CGFloat = .greatestFiniteMagnitude) {
        self.min = min
        self.max = max
    }
}

/// Only available in `FreeStackView`
class SpacerView: UIView, _Spacer {
    var min: CGFloat = .leastNonzeroMagnitude
    var max: CGFloat = .greatestFiniteMagnitude
    
    required init(min: CGFloat, max: CGFloat) {
        super.init(frame: .zero)
        
        self.min = min
        self.max = max
        
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public protocol _StackKitViewSpacerResultBuilder {
    static func buildExpression(_ expression: Spacer) -> [UIView]
}
extension _StackKitViewSpacerResultBuilder {
    public static func buildExpression(_ expression: Spacer) -> [UIView] {
        let spacer = SpacerView(min: expression.min, max: expression.max)
        return [spacer]
    }
}

extension _StackKitHStackContentResultBuilder: _StackKitViewSpacerResultBuilder { }
extension _StackKitVStackContentResultBuilder: _StackKitViewSpacerResultBuilder { }
extension _StackKitFreeStackViewContentResultBuilder: _StackKitViewSpacerResultBuilder { }


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
