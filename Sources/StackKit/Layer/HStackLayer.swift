import UIKit

open class HStackLayer: CALayer, StackLayer {
    
    public var alignment: HStackAlignment = .center
    public var distribution: HStackDistribution = .autoSpacing
    public var padding: UIEdgeInsets = .zero
    
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
        distribution: HStackDistribution = .spacing(2),
        padding: UIEdgeInsets = .zero,
        @_StackKitHStackLayerContentResultBuilder content: () -> [CALayer] = { [] }
    ) {
        super.init()
        
        self.alignment = alignment
        self.distribution = distribution
        self.padding = padding
        
        for l in content() {
            addSublayer(l)
        }
    }
    
    public func addContent(@_StackKitHStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        for v in content() {
            addSublayer(v)
        }
    }
    
    public func resetContent(@_StackKitHStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        sublayers?.forEach { $0.removeFromSuperlayer() }
        for v in content() {
            addSublayer(v)
        }
    }
    
    public var contentSize: CGSize {
        let h = effectiveSublayers.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.width
        let w = effectiveSublayers.map({ $0.bounds }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.height
        return CGSize(width: h + paddingRight, height: w + paddingVertically)
    }
    
    open override func preferredFrameSize() -> CGSize {
        setNeedsLayout()
        setNeedsDisplay()
        return contentSize
    }
    
    open func refreshSublayers() {
        for v in sublayers ?? [] where v.frame.size == .zero {
            v.frame.size = v.preferredFrameSize()
        }
    }
    
    private func makeSublayersAlignment() {
        switch alignment {
        case .top:
            effectiveSublayers.forEach { $0.frame.origin.y = _stackContentRect.minY }
        case .center:
            effectiveSublayers.forEach { $0.position.y = _stackContentRect.midY }
        case .bottom:
            effectiveSublayers.forEach { $0.frame.origin.y = _stackContentRect.maxY - $0.frame.height }
        }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        refreshSublayers()
        
        makeSublayersAlignment()
        
        switch distribution {
        case .spacing(let spacing):
            fillDivider()
            fillSpecifySpacer()
            fillSpacer()
            
            makeSpacing(spacing)
            
        case .autoSpacing:
            fillDivider()
            fillSpecifySpacer()
            fillSpacer()
            
            let spacing = autoSpacing()
            makeSpacing(spacing)
            
        case .fillHeight(let spacing): // autoSpacing and fill height
            fillDivider()
            fillSpecifySpacer()
            fillSpacer()
            
            let spacing = spacing ?? autoSpacing()
            makeSpacing(spacing)
            fillHeight()
            
        case .fill:
            fillDivider()
            fillSpecifySpacer()
            fillSpacer()
            fillWidth()
            makeSpacing(0)
            fillHeight()
        }
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        
        return contentSize
    }
    
    public func sizeToFit() {
        frame.size = sizeThatFits(.zero)
    }
}

extension HStackLayer {
    
    private func autoSpacing() -> CGFloat {
        let unspacerViews = viewsWithoutSpacer()
        let spacersCount = spacerLayers().map({ isSpacerBetweenInTwoLayers(spacerLayer: $0) }).filter({ $0 }).count
        let number = unspacerViews.count - spacersCount - 1
        return Swift.max(0, (_stackContentRect.width - viewsWidth() - lengthOfAllFixedLengthSpacer()) / CGFloat(max(1, number)))
    }
    
    private func viewsWidth() -> CGFloat {
        viewsWithoutSpacer().map({ $0.frame.width }).reduce(0, +)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, sublayer) in effectiveSublayers.enumerated() {
            if index == 0 {
                sublayer.frame.origin.x = paddingLeft
            } else {
                let previousLayer = effectiveSublayers[index - 1]
                if (previousLayer as? SpacerLayer) != nil || (sublayer as? SpacerLayer) != nil {
                    // spacer and view no spacing
                    sublayer.frame.origin.x = previousLayer.frame.maxX
                } else {
                    sublayer.frame.origin.x = previousLayer.frame.maxX + spacing
                }
            }
        }
    }
    
    private func fillHeight() {
        if frame.height == 0 {
            frame.size.height = contentSize.height
        }
        for sublayer in effectiveSublayers {
            sublayer.frame.size.height = _stackContentHeight
            
            guard alignment == .center else {
                continue
            }
            sublayer.position.y = _stackContentRect.midY
        }
    }
    
    private func fillWidth() {
        let maxW = _stackContentRect.width - lengthOfAllFixedLengthSpacer() - lengthOfAllFixedLengthDivier()
        var w = (maxW) / CGFloat(viewsWithoutSpacerAndDivider().count)
        
        let unspacersView = viewsWithoutSpacerAndDivider()
        w = maxW / CGFloat(unspacersView.count)
        for subview in unspacersView {
            subview.frame.size.width = w
        }
    }
}

extension HStackLayer {
    
    private func fillDivider() {
        let maxWidth = effectiveSublayers.filter({ ($0 as? DividerLayer) == nil }).map({ $0.frame.size.height }).max() ?? _stackContentRect.height
        for divider in effectiveSublayers.compactMap({ $0 as? DividerLayer }) {
            var maxLength = divider.maxLength
            if maxLength == .greatestFiniteMagnitude {
                // auto
                maxLength = maxWidth
            } else if maxWidth < maxLength {
                maxLength = maxWidth
            }
            divider.frame.size.height = maxLength
        }
    }
    
}

// MARK: Spacer
extension HStackLayer {
    
    private func fillSpecifySpacer() {
        let spacers = effectiveSublayers.compactMap({ $0 as? SpacerLayer })
        for spacer in spacers {
            spacer.fitSize(value: 0, for: .width)
        }
    }
    
    /// 填充 spacer
    ///
    /// A = viewsWithoutSpacer().widths
    /// B = frame.width - A - viewsWithoutSpacer.spacings
    private func fillSpacer() {
        let unspacerViews = viewsWithoutSpacer()
        guard unspacerViews.count != effectiveSublayers.count else { return }
        
        // 在 view 与 view 之间的 spacer view 数量: 两个 view 夹一个 spacer view
        let betweenInViewsCount = spacerLayers().map({ isSpacerBetweenInTwoLayers(spacerLayer: $0) }).filter({ $0 }).count
        // 非 spacer view 的总宽度
        let unspacerViewsWidth = viewsWidth()
        // 排除 spacer view 后的间距
        let unspacerViewsSpacing: CGFloat
        
        if unspacerViews.count == 1 {
            unspacerViewsSpacing = 0
        } else {
            switch distribution {
            case .spacing(let spacing):
                unspacerViewsSpacing = spacing * CGFloat(unspacerViews.count - betweenInViewsCount - 1) // 正常 spacing 数量: (views.count - 1), spacer 左右的视图没有间距，所以需要再排除在 view 之间的 spacer 数量
                
            case .fillHeight(let spacing):
                unspacerViewsSpacing = (spacing ?? autoSpacing()) * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .autoSpacing:
                unspacerViewsSpacing = autoSpacing() * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fill:
                unspacerViewsSpacing = 0
            }
        }
        
        // 非 spacerView 的所有宽度
        let unspacerViewsMaxWidth = unspacerViewsWidth + unspacerViewsSpacing
        let spacersWidth = (_stackContentWidth - unspacerViewsMaxWidth - self.lengthOfAllFixedLengthSpacer())
        let spacerWidth = spacersWidth / CGFloat(self.dynamicSpacerLayers().count)
        
        let spacerViews = self.spacerLayers()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerWidth, for: .width)
        }
    }
}
