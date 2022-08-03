import UIKit

open class VStackView: UIView {
    
    public var alignment: VStackAlignment = .center
    public var distribution: VStackDistribution = .autoSpacing
    
    open var effectiveSubviews: [UIView] {
        subviews.filter { $0.alpha > 0 && !$0.isHidden && $0.frame.size != .zero }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        switch alignment {
        case .left:
            effectiveSubviews.forEach { $0.frame.origin.y = 0 }
        case .center:
            effectiveSubviews.forEach { $0.center.y = frame.height / 2 }
        case .right:
            effectiveSubviews.forEach { $0.frame.origin.y = frame.height - $0.frame.height }
        }
        
        switch distribution {
        case .spacing(let spacing):
            makeSpacing(spacing)
            
        case .autoSpacing:
            let spacing = autoSpacing()
            makeSpacing(spacing)
            
        case .fillWidth:
            let spacing = autoSpacing()
            makeSpacing(spacing)
            fillWidth()
            
        case .fill:
            fillWidth()
            let w = frame.width / CGFloat(effectiveSubviews.count)
            effectiveSubviews.forEach {
                $0.frame.size.width = w
            }
        }
    }
}

extension VStackView {
    
    private func autoSpacing() -> CGFloat {
        (frame.height - effectiveSubviews.map({ $0.frame.size.height }).reduce(0, { $0 + $1 })) / CGFloat(effectiveSubviews.count)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, sublayer) in effectiveSubviews.enumerated() {
            if index == 0 {
                sublayer.frame.origin.x = 0
            } else {
                let previousLayer = effectiveSubviews[index - 1]
                sublayer.frame.origin.x = previousLayer.frame.maxX + spacing
            }
        }
    }
    
    private func fillWidth() {
        effectiveSubviews.forEach {
            $0.frame.size.width = frame.width
        }
    }
}
