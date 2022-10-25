import UIKit

///
/// All subviews(`UIView`) will be converted to `CALayer` to display.
/// 该类仅作展示使用，所有的 UIView 均会被转换为 CALayer 作为显示
///
/// There may be performance problems in heavy use. It is recommended to use `VStackView` / `HStackView` when there are many views.
/// 大量使用可能会有性能问题, 视图较多时建议直接使用 `VStackView` / `HStackView` 或使用 `H/VStackLayer` 替代.
///
open class HStackLayerWrapperView: _StackLayerWrapperView {
    
    open override class var layerClass: AnyClass {
        HStackLayer.self
    }
    
    public var hStackLayer: HStackLayer {
        self.layer as! HStackLayer
    }
    
    public required init(
        alignment: HStackAlignment = .center,
        distribution: HStackDistribution = .autoSpacing,
        padding: UIEdgeInsets = .zero,
        @_StackKitHStackContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        hStackLayer.alignment = alignment
        hStackLayer.distribution = distribution
        hStackLayer.padding = padding
        
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
