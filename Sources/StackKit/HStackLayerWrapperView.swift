import UIKit

/// 该类仅作展示使用，所有的 UIView 均会被转换为 CALayer 作为显示
open class HStackLayerWrapperView: UIView {
    
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
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        defer {
            subview.removeFromSuperview()
        }
        subview._tryFixSize()
        
        // Copy UIImageView
        if subview is UIImageView {
            let imageLayer = CALayer()
            imageLayer.contents = subview.layer.contents
            imageLayer.bounds = subview.layer.bounds
            imageLayer.backgroundColor = subview.layer.backgroundColor
            layer.addSublayer(imageLayer)
            return
        }
        
        // Divider View to Dividerlayer
        if let dividerView = subview as? DividerView {
            let dividerLayer = DividerLayer()
            dividerLayer.maxLength = dividerView.maxLength
            dividerLayer.frame.size.width = dividerView.thickness
            dividerLayer.backgroundColor = dividerView.backgroundColor?.cgColor
            dividerLayer.cornerRadius = dividerView.cornerRadius
            layer.addSublayer(dividerLayer)
            return
        }
        
        if let spacerView = subview as? SpacerView {
            let spacerLayer = spacerView.spacerLayer
            layer.addSublayer(spacerLayer)
            return
        }
        
        // render view to image and create CALayer with it
        // 如果直接使用 view.layer 可能显示会有问题, 例如: UILabel -> _UILabelLayer 无法正常显示文字
        let image = UIGraphicsImageRenderer(bounds: subview.bounds).image { context in
            subview.layer.render(in: context.cgContext)
        }
        let tempLayer = CALayer()
        tempLayer.contents = image.cgImage
        tempLayer.bounds = subview.bounds
        tempLayer.backgroundColor = subview.backgroundColor?.cgColor
        layer.addSublayer(tempLayer)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        hStackLayer.sizeThatFits(size)
    }
    
    open override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}
