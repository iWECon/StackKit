import UIKit

open class _StackLayerWrapperView: UIView {
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        defer {
            subview.removeFromSuperview()
        }
        
        // Copy UIImageView
        if convertUIImageView(subview) {
            return
        }
        if convertDividerView(subview) {
            return
        }
        if convertSpacerView(subview) {
            return
        }
        convertViewToImage(subview)
    }
    
    private func convertUIImageView(_ subview: UIView) -> Bool {
        guard let imageView = subview as? UIImageView else { return false }
        let imageLayer = CALayer()
        
        // fix subview.layer.contents is nil below on iOS 15?
        //
        // test on iOS 14.3, subview.layer.contents is nil,
        // test on iOS 15, subview.layer.contents has some value.
        // ⚠️ ❌ imageLayer.contents = subview.layer.contents
        
        imageLayer.contents = imageView.image?.cgImage
        imageLayer.bounds = subview.layer.bounds
        imageLayer.backgroundColor = subview.backgroundColor?.cgColor
        layer.addSublayer(imageLayer)
        
        return true
    }
    
    /// override in subclass
    open func convertDividerView(_ subview: UIView) -> Bool {
        false
    }
    
    private func convertSpacerView(_ subview: UIView) -> Bool {
        guard let spacerView = subview as? SpacerView else { return false }
        
        let spacerLayer = spacerView.spacerLayer
        layer.addSublayer(spacerLayer)
        
        return false
    }
    
    private func convertViewToImage(_ subview: UIView) {
        // render view to image and create CALayer with it
        //
        // If you use `view.layer` directly, there may be problems with display, for example: `UILabel` -> `_UILabelLayer` cannot display text normally
        // 如果直接使用 view.layer 可能显示会有问题, 例如: UILabel -> _UILabelLayer 无法正常显示文字
        let image = UIGraphicsImageRenderer(bounds: subview.bounds).image { context in
            subview.layer.render(in: context.cgContext)
        }
        let tempLayer = CALayer()
        tempLayer.contents = image.cgImage
        tempLayer.bounds = subview.bounds
        layer.addSublayer(tempLayer)
    }
    
    open override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}
