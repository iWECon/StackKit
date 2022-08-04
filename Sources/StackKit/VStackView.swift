import UIKit

open class VStackView: UIView {
    
    public var alignment: VStackAlignment = .center
    public var distribution: VStackDistribution = .autoSpacing
    
    public required init(
        alignment: VStackAlignment = .center,
        distribution: VStackDistribution = .autoSpacing,
        @_StackKitViewContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        
        self.alignment = alignment
        self.distribution = distribution
        
        for v in content() {
            addSubview(v)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    open var effectiveSubviews: [UIView] {
        subviews.filter { $0.alpha > 0 && !$0.isHidden && $0.frame.size != .zero }
    }
    
    public var contentSize: CGSize {
        effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
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
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSubviews()
        
        var _size = size
        if size.width == CGFloat.greatestFiniteMagnitude || size.width == 0 {
            _size.width = contentSize.width
        }
        if size.height == CGFloat.greatestFiniteMagnitude || size.height == 0 {
            _size.height = contentSize.height
        }
        return _size
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