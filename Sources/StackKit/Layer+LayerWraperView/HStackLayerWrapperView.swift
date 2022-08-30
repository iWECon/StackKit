import UIKit

///
/// All subviews(`UIView`) will be converted to `CALayer` to display
///
/// 该类仅作展示使用，所有的 UIView 均会被转换为 CALayer 作为显示
///
open class HStackLayerWrapperView: _StackLayerWrapperView {
    
    public var hStackLayer: HStackLayer {
        self.layer as! HStackLayer
    }
    
    open var alignment: HStackAlignment {
        get {
            hStackLayer.alignment
        }
        set {
            hStackLayer.alignment = newValue
        }
    }
    
    open var distribution: HStackDistribution {
        get {
            hStackLayer.distribution
        }
        set {
            hStackLayer.distribution = newValue
        }
    }
    
    public required init(
        alignment: HStackAlignment,
        distribution: HStackDistribution = .autoSpacing,
        @_StackKitHStackContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        hStackLayer.alignment = alignment
        hStackLayer.distribution = distribution
        
        for v in content() {
            addSubview(v)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func addContent(@_StackKitHStackContentResultBuilder _ content: () -> [UIView]) {
        for v in content() {
            addSubview(v)
        }
    }
    
    public func resetContent(@_StackKitHStackContentResultBuilder _ content: () -> [UIView]) {
        subviews.forEach { $0.removeFromSuperview() }
        for v in content() {
            addSubview(v)
        }
    }
    
    open override class var layerClass: AnyClass {
        HStackLayer.self
    }
    
    open override func convertDividerView(_ subview: UIView) -> Bool {
        guard let dividerView = subview as? DividerView else { return false }
        
        let dividerLayer = DividerLayer()
        dividerLayer.maxLength = dividerView.maxLength
        dividerLayer.frame.size.width = dividerView.thickness
        dividerLayer.backgroundColor = dividerView.backgroundColor?.cgColor
        dividerLayer.cornerRadius = dividerView.cornerRadius
        layer.addSublayer(dividerLayer)
        
        return true
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        hStackLayer.sizeThatFits(size)
    }
}
