import UIKit

///
/// All subviews(`UIView`) will be converted to `CALayer` to display.
/// 该类仅作展示使用，所有的 UIView 均会被转换为 CALayer 作为显示
///
/// There may be performance problems in heavy use. It is recommended to use `VStackView` / `HStackView` when there are many views.
/// 大量使用可能会有性能问题, 视图较多时建议直接使用 `VStackView` / `HStackView` 或使用 `H/VStackLayer` 替代.
///
open class VStackLayerWrapperView: _StackLayerWrapperView {
    
    open override class var layerClass: AnyClass {
        VStackLayer.self
    }
    
    public var vStackLayer: VStackLayer {
        self.layer as! VStackLayer
    }
    
    public required init(
        alignment: VStackAlignment = .center,
        distribution: VStackDistribution = .spacing(2),
        padding: UIEdgeInsets = .zero,
        @_StackKitVStackContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        vStackLayer.alignment = alignment
        vStackLayer.distribution = distribution
        vStackLayer.padding = padding
        
        addContent(content)
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
    
    open override func convertDividerView(_ subview: UIView) -> Bool {
        guard let dividerView = subview as? DividerView else { return false }
        
        let dividerLayer = DividerLayer()
        dividerLayer.maxLength = dividerView.maxLength
        dividerLayer.frame.size.height = dividerView.thickness
        dividerLayer.backgroundColor = dividerView.backgroundColor?.cgColor
        dividerLayer.cornerRadius = dividerView.cornerRadius
        layer.addSublayer(dividerLayer)
        
        return true
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        vStackLayer.sizeThatFits(size)
    }
    
}
