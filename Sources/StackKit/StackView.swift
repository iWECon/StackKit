import UIKit

protocol StackView {
    var effectiveSubviews: [UIView] { get }
    
    var padding: UIEdgeInsets { get }
    
    var contentSize: CGSize { get }
}

extension StackView where Self: UIView {
    var effectiveSubviews: [UIView] {
        subviews.filter { $0._isEffectiveView }
    }
}

// MARK: Padding
extension StackView {
    
    var paddingLeft: CGFloat {
        padding.left
    }
    var paddingRight: CGFloat {
        padding.right
    }
    var paddingHorizontally: CGFloat {
        padding.left + padding.right
    }
    
    var paddingTop: CGFloat {
        padding.top
    }
    var paddingBottom: CGFloat {
        padding.bottom
    }
    var paddingVertically: CGFloat {
        padding.top + padding.bottom
    }
    
}

extension StackView where Self: UIView {
    
    var _stackContentWidth: CGFloat {
        frame.width - (padding.left + padding.right)
    }
    
    var _stackContentHeight: CGFloat {
        frame.height - (padding.top + padding.bottom)
    }
    
    var _stackContentRect: CGRect {
        CGRect(x: padding.left, y: padding.top, width: _stackContentWidth, height: _stackContentHeight)
    }
}


// MARK: EffectiveSubviews
extension StackView {
    
    /// Filter `SpacerView` from effectiveSubviews
    func spacerViews() -> [SpacerView] {
        effectiveSubviews.compactMap({ $0 as? SpacerView })
    }
    
    /// All `SpacerView` that need to be calculated to get the length
    func dynamicSpacerViews() -> [SpacerView] {
        effectiveSubviews.compactMap({ $0 as? SpacerView }).filter({ $0.length == .greatestFiniteMagnitude })
    }
    
    /// Filter `DividerView` from effectiveSubviews
    func dividerViews() -> [DividerView] {
        effectiveSubviews.compactMap({ $0 as? DividerView })
    }
    
    func viewsWithoutSpacer() -> [UIView] {
        effectiveSubviews.filter({ ($0 as? SpacerView) == nil })
    }
    
    func viewsWithoutSpacerAndDivider() -> [UIView] {
        effectiveSubviews.filter({ ($0 as? SpacerView) == nil && ($0 as? DividerView) == nil })
    }
    
    /// The length of all fixed length Spacer
    func lengthOfAllFixedLengthSpacer() -> CGFloat {
        spacerViews().map { $0.setLength }.reduce(0, +)
    }
    
    func isSpacerBetweenInTwoViews(spacerView: SpacerView) -> Bool {
        guard let index = effectiveSubviews.firstIndex(of: spacerView) else {
            return false
        }
        
        guard effectiveSubviews.count >= 3 else {
            return false
        }
        
        let start: Int = 1
        let end: Int = effectiveSubviews.count - 2
        return (start ... end).contains(index)
    }
    
    func lengthOfAllFixedLengthDivider() -> CGFloat {
        dividerViews().map { $0.thickness }.reduce(0, +)
    }
}
