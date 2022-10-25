import UIKit

protocol StackLayer {
    var effectiveSublayers: [CALayer] { get }
    
    var padding: UIEdgeInsets { get }
    
    var contentSize: CGSize { get }
}

extension StackLayer where Self: CALayer {
    var effectiveSublayers: [CALayer] {
        (sublayers ?? []).filter { $0._isEffectiveLayer }
    }
}

// MARK: Padding
extension StackLayer {
    
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

extension StackLayer where Self: CALayer {
    
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

extension StackLayer where Self: CALayer {
    func spacerLayers() -> [SpacerLayer] {
        effectiveSublayers.compactMap({ $0 as? SpacerLayer })
    }
    func dynamicSpacerLayers() -> [SpacerLayer] {
        effectiveSublayers.compactMap({ $0 as? SpacerLayer }).filter({ $0.length == .greatestFiniteMagnitude })
    }
    func dividerLayers() -> [DividerLayer] {
        effectiveSublayers.compactMap({ $0 as? DividerLayer })
    }
    func viewsWithoutSpacer() -> [CALayer] {
        effectiveSublayers.filter({ ($0 as? SpacerLayer) == nil })
    }
    func viewsWithoutSpacerAndDivider() -> [CALayer] {
        effectiveSublayers.filter({ ($0 as? SpacerLayer) == nil && ($0 as? DividerLayer) == nil })
    }
    
    func lengthOfAllFixedLengthSpacer() -> CGFloat {
        spacerLayers().map { $0.setLength }.reduce(0, +)
    }
    func lengthOfAllFixedLengthDivier() -> CGFloat {
        dividerLayers().map { $0.thickness }.reduce(0, +)
    }
    
    func isSpacerBetweenInTwoLayers(spacerLayer: SpacerLayer) -> Bool {
        guard let index = effectiveSublayers.firstIndex(of: spacerLayer) else {
            return false
        }
        
        guard effectiveSublayers.count >= 3 else {
            return false
        }
        
        let start: Int = 1
        let end: Int = effectiveSublayers.count - 2
        return (start ... end).contains(index)
    }
    
}
