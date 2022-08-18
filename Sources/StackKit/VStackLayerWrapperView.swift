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
            addSubview(v)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func addContent(@_StackKitVStackContentResultBuilder _ content: () -> [UIView]) {
        for v in content() {
            addSubview(v)
        }
    }
    
    public func resetContent(@_StackKitVStackContentResultBuilder _ content: () -> [UIView]) {
        subviews.forEach { $0.removeFromSuperview() }
        for v in content() {
            addSubview(v)
        }
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
        
        // Copy UIImageView
        if let imageView = subview as? UIImageView {
            let imageLayer = CALayer()
            // fix subview.layer.contents is nil below on iOS 15?
            // test on iOS 14.3, subview.layer.contents is nil,
            // test on iOS 15, subview.layer.contents has some value.
//            imageLayer.contents = subview.layer.contents
            
            imageLayer.contents = imageView.image?.cgImage
            imageLayer.bounds = subview.layer.bounds
            imageLayer.backgroundColor = subview.backgroundColor?.cgColor
            layer.addSublayer(imageLayer)
            return
        }
        
        // Divider View to DividerLayer
        if let dividerView = subview as? DividerView {
            let dividerLayer = DividerLayer()
            dividerLayer.maxLength = dividerView.maxLength
            dividerLayer.frame.size.height = dividerView.thickness
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
        layer.addSublayer(tempLayer)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        vStackLayer.sizeThatFits(size)
    }
    
    open override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}
