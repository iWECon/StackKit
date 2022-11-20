import UIKit

open class VStackLayer: CALayer, StackLayer {
    
    public var alignment: VStackAlignment = .center
    public var distribution: VStackDistribution = .autoSpacing
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
        alignment: VStackAlignment = .center,
        distribution: VStackDistribution = .spacing(2),
        padding: UIEdgeInsets = .zero,
        @_StackKitVStackLayerContentResultBuilder content: () -> [CALayer] = { [] }
    ) {
        super.init()
        
        self.alignment = alignment
        self.distribution = distribution
        self.padding = padding
        
        addContent(content)
    }
    
    public func addContent(@_StackKitVStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        for v in content() {
            addSublayer(v)
        }
    }
    
    public func resetContent(@_StackKitVStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        sublayers?.forEach { $0.removeFromSuperlayer() }
        addContent(content)
    }
    
    public var contentSize: CGSize {
        let h = effectiveSublayers.map({ $0.frame }).reduce(CGRect.zero) { partialResult, rect in
            partialResult.union(rect)
        }.height
        let w = effectiveSublayers.map({ $0.bounds }).reduce(CGRect.zero) { partialResult, rect in
            partialResult.union(rect)
        }.width
        return CGSize(width: w + paddingHorizontally, height: h + paddingBottom)
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
        case .left:
            effectiveSublayers.forEach { $0.frame.origin.x = _stackContentRect.minX }
        case .center:
            effectiveSublayers.forEach { $0.position.x = _stackContentRect.midX }
        case .right:
            effectiveSublayers.forEach { $0.frame.origin.x = _stackContentRect.maxX - $0.frame.width }
        }
    }
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        
        refreshSublayers()
        
        makeSublayersAlignment()
        
        fillDivider()
        fillSpecifySpacer()
        fillSpacer()
        
        switch distribution {
        case .spacing(let spacing):
            makeSpacing(spacing)
            
        case .autoSpacing:
            let spacing = autoSpacing()
            makeSpacing(spacing)
            
        case .fillWidth(let spacing):
            let spacing = spacing ?? autoSpacing()
            makeSpacing(spacing)
            fillWidth()
            
        case .fill:
            fillHeight()
            makeSpacing(0)
            fillWidth()
        }
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        
        return contentSize
    }
    
    public func sizeToFit() {
        let size = sizeThatFits(.zero)
        self.frame.size = size
    }
}

extension VStackLayer {
    
    private func autoSpacing() -> CGFloat {
        let unspacerViews = viewsWithoutSpacer()
        let spacersCount = spacerLayers().map({ isSpacerBetweenInTwoLayers(spacerLayer: $0) }).filter({ $0 }).count
        let number = unspacerViews.count - spacersCount - 1
        return Swift.max(0, (_stackContentRect.height - viewsHeight() - lengthOfAllFixedLengthSpacer()) / CGFloat(max(1, number)))
    }
    
    private func viewsHeight() -> CGFloat {
        viewsWithoutSpacer().map({ $0.frame.height }).reduce(0, +)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, sublayer) in effectiveSublayers.enumerated() {
            if index == 0 {
                sublayer.frame.origin.y = paddingTop
            } else {
                let previousLayer = effectiveSublayers[index - 1]
                if (previousLayer as? SpacerLayer) != nil || (sublayer as? SpacerLayer) != nil {
                    // spacer and view no spacing
                    sublayer.frame.origin.y = previousLayer.frame.maxY
                } else {
                    sublayer.frame.origin.y = previousLayer.frame.maxY + spacing
                }
            }
        }
    }
    
    private func fillWidth() {
        if frame.width == 0 {
            frame.size.width = _stackContentRect.width
        }
        for sublayer in effectiveSublayers {
            sublayer.frame.size.width = _stackContentWidth

            guard alignment == .center else {
                continue
            }
            sublayer.position.x = _stackContentRect.midX
        }
    }
    
    ///
    /// 填充高度, 所有视图（排除 spacer）高度一致
    private func fillHeight() {
        let maxH = _stackContentRect.height - lengthOfAllFixedLengthSpacer() - lengthOfAllFixedLengthDivier()
        var h = (maxH) / CGFloat(viewsWithoutSpacerAndDivider().count)
        
        let unspacersView = viewsWithoutSpacerAndDivider()
        h = maxH / CGFloat(unspacersView.count)
        for subview in unspacersView {
            subview.frame.size.height = h
        }
    }
}

extension VStackLayer {
    
    private func fillDivider() {
        let maxWidth = effectiveSublayers.filter({ ($0 as? DividerLayer) == nil }).map({ $0.frame.size.width }).max() ?? _stackContentRect.width
        for divider in effectiveSublayers.compactMap({ $0 as? DividerLayer }) {
            var maxLength = divider.maxLength
            if maxLength == .greatestFiniteMagnitude {
                // auto
                maxLength = maxWidth
            } else if maxWidth < maxLength {
                maxLength = maxWidth
            }
            divider.frame.size.width = maxLength
        }
    }
    
}

// MARK: Spacer
extension VStackLayer {
    
    private func fillSpecifySpacer() {
        let spacers = effectiveSublayers.compactMap({ $0 as? SpacerLayer })
        for spacer in spacers {
            spacer.fitSize(value: 0, for: .height)
        }
    }
    
    /// 填充 spacer
    private func fillSpacer() {
        let unspacerViews = viewsWithoutSpacer()
        guard unspacerViews.count != effectiveSublayers.count else { return }
        
        let betweenInViewsCount = spacerLayers().map({ isSpacerBetweenInTwoLayers(spacerLayer: $0) }).filter({ $0 }).count
        let unspacerViewsHeight = viewsHeight()
        // 排除 spacer view 后的间距
        let unspacerViewsSpacing: CGFloat
        
        if unspacerViews.count == 1 {
            unspacerViewsSpacing = 0
        } else {
            switch distribution {
            case .spacing(let spacing):
                unspacerViewsSpacing = spacing * CGFloat(unspacerViews.count - betweenInViewsCount - 1) // 正常 spacing 数量: (views.count - 1), spacer 左右的视图没有间距，所以需要再排除在 view 之间的 spacer 数量
                
            case .fillWidth(let spacing):
                unspacerViewsSpacing = (spacing ?? autoSpacing()) * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .autoSpacing:
                unspacerViewsSpacing = autoSpacing() * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fill:
                unspacerViewsSpacing = 0
            }
        }
        
        let unspacerViewsMaxHeight = unspacerViewsHeight + unspacerViewsSpacing
        let spacersHeight = (_stackContentRect.height - unspacerViewsMaxHeight - self.lengthOfAllFixedLengthSpacer())
        let spacerWidth = spacersHeight / CGFloat(self.dynamicSpacerLayers().count)
        
        let spacerViews = self.spacerLayers()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerWidth, for: .height)
        }
    }
}
