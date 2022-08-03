import UIKit

open class VStackLayer: CALayer {
    
    public enum Alignment {
        case left
        case center
        case right
    }
    
    public enum Distribution {
        /// specify spacing
        case spacing(_ spacing: CGFloat)
        
        /// automatic calculate spacing
        /// should set height?
        case autoSpacing
        
        /// fill width
        case fillWidth
        
        /// fill width and height (height may equal)
        /// should set height?
        case fill
    }
    
    public var alignment: Alignment = .center
    public var distribution: Distribution = .autoSpacing
    
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
        alignment: Alignment = .center,
        distribution: Distribution = .autoSpacing,
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
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        
        refreshSublayers()
        
        switch alignment {
        case .left:
            effectiveSublayers.forEach {
                $0.frame.origin.x = 0
            }
        case .center:
            effectiveSublayers.forEach {
                $0.position.x = frame.width / 2
            }
        case .right:
            effectiveSublayers.forEach {
                $0.frame.origin.x = frame.width - $0.frame.width
            }
        }
        
        switch distribution {
        case .spacing(let spacing):
            makeSpacing(spacing)
            
        case .autoSpacing:
            let spacing = (frame.height - effectiveSublayers.map({ $0.frame.size.height }).reduce(0, { $0 + $1 })) / CGFloat(effectiveSublayers.count)
            makeSpacing(spacing)
            
        case .fillWidth:
            let spacing = (frame.height - effectiveSublayers.map({ $0.frame.size.height }).reduce(0, { $0 + $1 })) / CGFloat(effectiveSublayers.count)
            makeSpacing(spacing)
            fillWidth()
            
        case .fill:
            fillWidth()
            
            let h = frame.height / CGFloat(effectiveSublayers.count)
            effectiveSublayers.forEach {
                $0.frame.size.height = h
            }
        }
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSublayers()
        return preferredFrameSize()
    }
}

extension VStackLayer {
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, sublayer) in effectiveSublayers.enumerated() {
            if index == 0 {
                sublayer.frame.origin.y = 0
            } else {
                let previousLayer = effectiveSublayers[index - 1]
                sublayer.frame.origin.y = previousLayer.frame.maxY + spacing
            }
        }
    }
    
    private func fillWidth() {
        effectiveSublayers.forEach {
            $0.frame.size.width = frame.width
        }
    }
}
