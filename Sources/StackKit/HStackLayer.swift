import UIKit

open class HStackLayer: CALayer {
    
    public var alignment: HStackAlignment = .center
    public var distribution: HStackDistribution = .autoSpacing
    
    public var contentSize: CGSize {
        effectiveSublayers.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
    }
    
    open override func preferredFrameSize() -> CGSize {
        contentSize
    }
    
    public required override init() {
        super.init()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public required init(
        alignment: HStackAlignment = .center,
        distribution: HStackDistribution = .autoSpacing,
        @_StackKitLayerContentResultBuilder content: () -> [CALayer] = { [] }
    ) {
        super.init()
        
        self.alignment = alignment
        self.distribution = distribution
        
        for l in content() {
            addSublayer(l)
        }
    }
    
    open var effectiveSublayers: [CALayer] {
        (sublayers ?? []).lazy.filter { $0.opacity > 0 && !$0.isHidden && $0.frame.size != .zero }
    }
    
    open func refreshSublayers() {
        for v in sublayers ?? [] {
            v.frame.size = v.preferredFrameSize()
        }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        refreshSublayers()
        
        switch alignment {
        case .top:
            effectiveSublayers.forEach { $0.frame.origin.y = 0 }
        case .center:
            effectiveSublayers.forEach { $0.position.y = frame.height / 2 }
        case .bottom:
            effectiveSublayers.forEach { $0.frame.origin.y = frame.height - $0.frame.height }
        }
        
        switch distribution {
        case .spacing(let spacing):
            makeSpacing(spacing)
            
        case .autoSpacing:
            let spacing = autoSpacing()
            makeSpacing(spacing)
            
        case .fillHeight: // autoSpacing and fill height
            let spacing = autoSpacing()
            makeSpacing(spacing)
            fillHeight()
            
        case .fill:
            fillHeight()
            
            let w = frame.width / CGFloat(effectiveSublayers.count)
            effectiveSublayers.forEach {
                $0.frame.size.width = w
            }
        }
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSublayers()
        
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

extension HStackLayer {
    
    private func autoSpacing() -> CGFloat {
        (frame.width - effectiveSublayers.map({ $0.frame.size.width }).reduce(0, { $0 + $1 })) / CGFloat(effectiveSublayers.count)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, sublayer) in effectiveSublayers.enumerated() {
            if index == 0 {
                sublayer.frame.origin.x = 0
            } else {
                let previousLayer = effectiveSublayers[index - 1]
                sublayer.frame.origin.x = previousLayer.frame.maxX + spacing
            }
        }
    }
    
    private func fillHeight() {
        effectiveSublayers.forEach {
            $0.frame.size.height = frame.height
        }
    }
}
