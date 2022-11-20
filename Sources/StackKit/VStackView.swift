import UIKit

open class VStackView: UIView, StackView {
    
    public var alignment: VStackAlignment = .center
    public var distribution: VStackDistribution = .autoSpacing
    public var padding: UIEdgeInsets = .zero
    
    public required init(
        alignment: VStackAlignment = .center,
        distribution: VStackDistribution = .spacing(2),
        padding: UIEdgeInsets = .zero,
        @_StackKitVStackContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        
        self.alignment = alignment
        self.distribution = distribution
        self.padding = padding
        
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
        addContent(content)
    }
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        // keep spacers between views and spacers have only one spacer
        guard (subview as? SpacerView) != nil,
              let index = subviews.firstIndex(where: { $0 == subview })
        else {
            return
        }
        
        let previousIndex = index - 1
        if previousIndex > 0, previousIndex < subviews.count - 1 {
            if (subviews[previousIndex] as? SpacerView) != nil {
                subview.removeFromSuperview()
            }
        }
        
        let nextIndex = index + 1
        if nextIndex > 0, nextIndex < subviews.count - 1 {
            if (subviews[nextIndex] as? SpacerView) != nil {
                subview.removeFromSuperview()
            }
        }
    }
    
    public var contentSize: CGSize {
        let h = effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.height
        let w = effectiveSubviews.map({ $0.bounds }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.width
        return CGSize(width: w + paddingHorizontally, height: h + paddingBottom)
    }
    
    open func hideIfNoEffectiveViews() {
        self.isHidden = effectiveSubviews.isEmpty
    }
    
    private func tryResizeStackView() {
        subviews.forEach { fitSize in
            fitSize._fitSize(with: fitSize._stackKit_fitType)
        }
    }
    
    private func makeSubviewsAlignment() {
        switch alignment {
        case .left:
            effectiveSubviews.forEach { $0.frame.origin.x = _stackContentRect.minX }
        case .center:
            effectiveSubviews.forEach { $0.center.x = _stackContentRect.midX }
        case .right:
            effectiveSubviews.forEach { $0.frame.origin.x = _stackContentRect.maxX - $0.frame.width }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        tryResizeStackView()
        
        makeSubviewsAlignment()
        
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
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        
        return contentSize
    }
    
    open override func sizeToFit() {
        _fitSize(with: self._stackKit_fitType)
    }
    
    open override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}

extension VStackView {
    
    private func autoSpacing() -> CGFloat {
        let unspacerViews = viewsWithoutSpacer()
        let spacersCount = spacerViews().map({ isSpacerBetweenInTwoViews(spacerView: $0) }).filter({ $0 }).count
        let number = unspacerViews.count - spacersCount - 1
        return (_stackContentRect.height - viewsHeight() - lengthOfAllFixedLengthSpacer()) / CGFloat(max(1, number))
    }
    
    private func viewsHeight() -> CGFloat {
        viewsWithoutSpacer().map({ $0.frame.height }).reduce(0, +)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, subview) in effectiveSubviews.enumerated() {
            if index == 0 {
                subview.frame.origin.y = paddingTop
            } else {
                let previousView = effectiveSubviews[index - 1]
                if (previousView as? SpacerView) != nil || (subview as? SpacerView) != nil { // spacer and view no spacing
                    subview.frame.origin.y = previousView.frame.maxY
                } else {
                    subview.frame.origin.y = previousView.frame.maxY + spacing
                }
            }
        }
    }
    
    private func fillWidth() {
        if frame.width == 0 {
            frame.size.width = contentSize.width // found subviews.map { $0.frame.width }.max()
        }
        for subview in effectiveSubviews {
            subview.frame.size.width = _stackContentWidth
            
            // fix #https://github.com/iWECon/StackKit/issues/21
            guard alignment == .center else {
                continue
            }
            subview.center.x = _stackContentRect.midX
        }
    }
    
    /// 填充高度, 所有视图（排除 spacer）高度一致
    private func fillHeight() {
        let maxH = _stackContentRect.height - lengthOfAllFixedLengthSpacer() - lengthOfAllFixedLengthDivider()
        var h = (maxH) / CGFloat(viewsWithoutSpacerAndDivider().count)
        
        let unspacersView = viewsWithoutSpacerAndDivider()
        h = maxH / CGFloat(unspacersView.count)
        for subview in unspacersView {
            subview.frame.size.height = h
        }
    }
}

// MARK: Divider
extension VStackView {
    
    private func fillDivider() {
        let maxWidth = effectiveSubviews.filter({ ($0 as? DividerView) == nil }).map({ $0.frame.size.width }).max() ?? _stackContentRect.width
        for divider in effectiveSubviews.compactMap({ $0 as? DividerView }) {
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
extension VStackView {
    
    /// 填充 spacer 最小值
    private func fillSpecifySpacer() {
        let spacers = effectiveSubviews.compactMap({ $0 as? SpacerView })
        for spacer in spacers {
            spacer.fitSize(value: 0, for: .height)
        }
    }
    
    private func fillSpacer() {
        let unspacerViews = viewsWithoutSpacer()
        guard unspacerViews.count != effectiveSubviews.count else { return }
        
        // 在 view 与 view 之间的 spacer view 数量: 两个 view 夹一个 spacer view
        let betweenInViewsCount = spacerViews().map({ isSpacerBetweenInTwoViews(spacerView: $0) }).filter({ $0 }).count
        // 非 spacer view 的总高度
        let unspacerViewsHeight = viewsHeight()
        // 排除 spacer view 后的间距
        let unspacerViewsSpacing: CGFloat
        
        if unspacerViews.count == 1 {
            unspacerViewsSpacing = 0
        } else {
            switch distribution {
            case .spacing(let spacing):
                // 正常 spacing 数量: (views.count - 1), spacer 左右的视图没有间距，所以需要再排除在 view 之间的 spacer 数量
                unspacerViewsSpacing = spacing * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fillWidth(let spacing):
                unspacerViewsSpacing = (spacing ?? autoSpacing()) * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .autoSpacing:
                unspacerViewsSpacing = autoSpacing() * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fill:
                unspacerViewsSpacing = 0
            }
        }
        
        // 非 spacerView 的所有宽度
        let unspacerViewsMaxHeight = unspacerViewsHeight + unspacerViewsSpacing
        let spacersHeight = (_stackContentRect.height - unspacerViewsMaxHeight - self.lengthOfAllFixedLengthSpacer())
        let spacerHeight = spacersHeight / CGFloat(self.dynamicSpacerViews().count)
        
        let spacerViews = self.spacerViews()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerHeight, for: .height)
        }
    }
}
