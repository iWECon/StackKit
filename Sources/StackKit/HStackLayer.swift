import UIKit

@resultBuilder
public struct HStackLayerContent {
    public static func buildBlock(_ components: CALayer...) -> [CALayer] {
        components
    }
}

open class HStackLayer: CALayer {
    
    public enum Alignment {
        case top
        case center
        case bottom
    }
    
    public enum Distribution {
        case specifySpacing(_ spacing: CGFloat)
        case equalSpacing
        case equalWidth
        case equalSpacingAround
    }
    
    open var alignment: Alignment = .center
    open var distribution: Distribution = .equalSpacing
    
    /// init
    /// - Parameters:
    ///   - alignment: alignment of subLayers
    ///   - distribution: default is `.equalSpacing`
    public convenience init(
        alignment: Alignment,
        distribution: Distribution = .equalSpacing,
        @HStackLayerContent content: () -> [CALayer] = { [] }
    ) {
        self.init()
        
        self.alignment = alignment
        self.distribution = distribution
        
        for l in content() {
            addSublayer(l)
        }
    }
    
    // call view size layout
    public func refreshSublayers() {
        for v in sublayers ?? [] {
            guard v.frame.size == .zero else { continue }
            v.frame.size = v.preferredFrameSize()
        }
    }
    
    open var validatedSublayers: [CALayer] {
        (sublayers ?? []).lazy.filter { $0.opacity > 0 && !$0.isHidden && $0.frame.size != .zero }
    }
    
    open var contentWidth: CGFloat {
        validatedSublayers.map { $0.frame.width }.reduce(0, { $0 + $1 })
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        refreshSublayers()
        
        switch alignment {
        case .top:
            validatedSublayers.forEach { $0.frame.origin.y = 0 }
        case .center:
            validatedSublayers.forEach { $0.position.y = frame.height / 2 }
        case .bottom:
            validatedSublayers.forEach { $0.frame.origin.y = frame.height - $0.frame.height }
        }
        
        switch distribution {
        case .specifySpacing(let spacing):
            for (index, v) in validatedSublayers.enumerated() {
                if index == 0 {
                    v.frame.origin.x = 0
                } else {
                    let previousV = validatedSublayers[index - 1]
                    v.frame.origin.x = previousV.frame.maxX + spacing
                }
            }
            
        case .equalSpacing:
            // 左右到头, 中间间距相等
            if validatedSublayers.count == 1 {
                validatedSublayers.first?.position.x = frame.width / 2
            } else {
                let spacing = (frame.width - contentWidth) / CGFloat(validatedSublayers.count - 1)
                for (index, v) in validatedSublayers.enumerated() {
                    if index == 0 {
                        v.frame.origin.x = 0
                    } else {
                        let previousV = validatedSublayers[index - 1]
                        v.frame.origin.x = previousV.frame.maxX + spacing
                    }
                }
            }
        case .equalWidth:
            if validatedSublayers.count == 1 {
                validatedSublayers.first?.frame.size.width = frame.width
            } else if validatedSublayers.count > 0 {
                let equalWidth = frame.width / CGFloat(validatedSublayers.count)
                for (index, v) in validatedSublayers.enumerated() {
                    if index == 0 {
                        v.frame.origin.x = 0
                        v.frame.size.width = equalWidth
                    } else {
                        let previousV = validatedSublayers[index - 1]
                        v.frame.origin.x = previousV.frame.maxX
                        v.frame.size.width = equalWidth
                    }
                }
            }
        case .equalSpacingAround:
            if validatedSublayers.count == 1 {
                validatedSublayers.first?.position.x = frame.width / 2
            } else {
                let equalSpacing = (frame.width - contentWidth) / CGFloat(validatedSublayers.count + 1)
                for (index, v) in validatedSublayers.enumerated() {
                    if index == 0 {
                        v.frame.origin.x = equalSpacing
                    } else {
                        let previousV = validatedSublayers[index - 1]
                        v.frame.origin.x = previousV.frame.maxX + equalSpacing
                    }
                }
            }
        }
    }
    
    // TODO: calculate size
    func sizeThatFits(_ size: CGSize) -> CGSize {
        size
    }
}
