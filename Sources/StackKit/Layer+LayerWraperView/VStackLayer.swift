import UIKit

open class VStackLayer: CALayer, _StackLayerProvider {
    
    public var alignment: VStackAlignment = .center
    public var distribution: VStackDistribution = .autoSpacing
    
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
        distribution: VStackDistribution = .autoSpacing,
        @_StackKitVStackLayerContentResultBuilder content: () -> [CALayer] = { [] }
    ) {
        super.init()
        
        self.alignment = alignment
        self.distribution = distribution
        
        for l in content() {
            addSublayer(l)
        }
    }
    
    public func addContent(@_StackKitVStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        for v in content() {
            addSublayer(v)
        }
    }
    
    public func resetContent(@_StackKitVStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        sublayers?.forEach { $0.removeFromSuperlayer() }
        for v in content() {
            addSublayer(v)
        }
    }
    
    public var contentSize: CGSize {
        effectiveSublayers.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
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
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        
        refreshSublayers()
        
        switch alignment {
        case .left:
            effectiveSublayers.forEach {
                $0.frame.origin.x = 0
            }
        case .center:
            effectiveSublayers.forEach {
                $0.position.x = frame.width / 2
            }
        case .right:
            effectiveSublayers.forEach {
                $0.frame.origin.x = frame.width - $0.frame.width
            }
        }
        
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
            
        case .fillWidth:
            fillDivider()
            fillSpecifySpacer()
            fillSpacer()
            
            let spacing = autoSpacing()
            makeSpacing(spacing)
            fillWidth()
            
        case .fill:
            fillDivider()
            fillSpecifySpacer()
            fillSpacer()
            fillHeight()
            makeSpacing(0)
            fillWidth()
        }
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSublayers()
        
        var _size = size
        if size.width == CGFloat.greatestFiniteMagnitude || size.width == 0 {
            _size.width = contentSize.width
        }
        if size.height == CGFloat.greatestFiniteMagnitude || size.height == 0 {
            _size.height = contentSize.height
        }
        return _size
    }
    
    public func sizeToFit() {
        let size = sizeThatFits(.zero)
        self.frame.size = size
    }
}

extension VStackLayer {
    
    private func autoSpacing() -> CGFloat {
        let unspacerViews = viewsWithoutSpacer()
        let spacersCount = spacerLayers().map({ isSpacerBetweenViews($0) }).filter({ $0 }).count
        let number = unspacerViews.count - spacersCount - 1
        return Swift.max(0, (frame.height - viewsHeight() - lengthOfAllFixedLengthSpacer()) / CGFloat(max(1, number)))
    }
    
    private func viewsHeight() -> CGFloat {
        viewsWithoutSpacer().map({ $0.frame.height }).reduce(0, +)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, sublayer) in effectiveSublayers.enumerated() {
            if index == 0 {
                sublayer.frame.origin.y = 0
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
        effectiveSublayers.forEach {
            $0.frame.size.width = frame.width
        }
    }
    
    ///
    /// 填充高度, 所有视图（排除 spacer）高度一致
    private func fillHeight() {
        let maxH = frame.height - lengthOfAllFixedLengthSpacer() - dividerSpecifyLength()
        var h = (maxH) / CGFloat(viewsWithoutSpacerAndDivider().count)
        
        let unspacersView = viewsWithoutSpacerAndDivider()
        h = maxH / CGFloat(unspacersView.count)
        for subview in unspacersView {
            subview.frame.size.height = h
        }
    }
}

extension VStackLayer {
    
    private func dividerSpecifyLength() -> CGFloat {
        dividerLayers()
            .map({ $0.thickness })
            .reduce(0, +)
    }
    
    private func fillDivider() {
        let maxWidth = effectiveSublayers.filter({ ($0 as? DividerLayer) == nil }).map({ $0.frame.size.width }).max() ?? frame.width
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
    
    // 取出固定 length 的 spacer
    private func lengthOfAllFixedLengthSpacer() -> CGFloat {
        spacerLayers()
            .map({ $0.setLength })
            .reduce(0, +)
    }
    
    private func isSpacerBetweenViews(_ spacer: SpacerLayer) -> Bool {
        guard let index = effectiveSublayers.firstIndex(of: spacer) else {
            return false
        }
        
        guard effectiveSublayers.count >= 3 else {
            return false
        }
        
        let start: Int = 1
        let end: Int = effectiveSublayers.count - 2
        return (start ... end).contains(index)
    }
    
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
        
        let betweenInViewsCount = spacerLayers().map({ isSpacerBetweenViews($0) }).filter({ $0 }).count
        let unspacerViewsHeight = viewsHeight()
        // 排除 spacer view 后的间距
        let unspacerViewsSpacing: CGFloat
        
        if unspacerViews.count == 1 {
            unspacerViewsSpacing = 0
        } else {
            switch distribution {
            case .spacing(let spacing):
                unspacerViewsSpacing = spacing * CGFloat(unspacerViews.count - betweenInViewsCount - 1) // 正常 spacing 数量: (views.count - 1), spacer 左右的视图没有间距，所以需要再排除在 view 之间的 spacer 数量
                
            case .autoSpacing, .fillWidth:
                unspacerViewsSpacing = autoSpacing() * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fill:
                unspacerViewsSpacing = 0
            }
        }
        
        let unspacerViewsMaxHeight = unspacerViewsHeight + unspacerViewsSpacing
        let spacersHeight = (frame.height - unspacerViewsMaxHeight - self.lengthOfAllFixedLengthSpacer())
        let spacerWidth = spacersHeight / CGFloat(self.dynamicSpacerLayers().count)
        
        let spacerViews = self.spacerLayers()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerWidth, for: .height)
        }
    }
}
