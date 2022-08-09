import UIKit

/// 该类仅作展示使用，所有的 UIView 均会被转换为 CALayer 作为显示
open class VStackLayerWrapperView: UIView {
    
    public var vStackLayer: VStackLayer {
        self.layer as! VStackLayer
    }
    
    open var alignment: VStackAlignment {
        get {
            vStackLayer.alignment
        }
        set {
            vStackLayer.alignment = newValue
        }
    }
    
    open var distribution: VStackDistribution {
        get {
            vStackLayer.distribution
        }
        set {
            vStackLayer.distribution = newValue
        }
    }
    
    public required init(
        alignment: VStackAlignment,
        distribution: VStackDistribution = .fillWidth,
        @_StackKitVStackContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        vStackLayer.alignment = alignment
        vStackLayer.distribution = distribution
        
        for v in content() {
            appendView(v)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override class var layerClass: AnyClass {
        VStackLayer.self
    }
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        defer {
            subview.removeFromSuperview()
        }
        subview._tryFixSize()
        
        // use view.layer if view is UIImageView
        if subview is UIImageView {
            layer.addSublayer(subview.layer)
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
        layer.addSublayer(tempLayer)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        vStackLayer.sizeThatFits(size)
    }
    
    open override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}
