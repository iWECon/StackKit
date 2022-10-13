import UIKit

open class HStackView: UIView, StackView {
    
    public var alignment: HStackAlignment = .center
    public var distribution: HStackDistribution = .autoSpacing
    public var padding: UIEdgeInsets = .zero
    
    public required init(
        alignment: HStackAlignment = .center,
        distribution: HStackDistribution = .spacing(2),
        padding: UIEdgeInsets = .zero,
        @_StackKitHStackContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        
        self.alignment = alignment
        self.distribution = distribution
        self.padding = padding
        
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
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        subview._tryFixSize()
        
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
    
    open var effectiveSubviews: [UIView] {
        subviews.filter { $0._isEffectiveView }
    }
    
    public var contentSize: CGSize {
        let h = effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.width
        let w = effectiveSubviews.map({ $0.bounds }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.height
        return CGSize(width: h + paddingRight, height: w + paddingVertically)
    }
    
    open func hideIfNoEffectiveViews() {
        self.isHidden = effectiveSubviews.isEmpty
    }
    
    private func tryResizeStackView() {
        subviews.forEach { fitSize in
            fitSize._fitSize(with: fitSize._stackKit_fitType)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        tryResizeStackView()
        
        switch alignment {
        case .top:
            effectiveSubviews.forEach { $0.frame.origin.y = _stackContentRect.minY }
        case .center:
            effectiveSubviews.forEach { $0.center.y = _stackContentRect.midY }
        case .bottom:
            effectiveSubviews.forEach { $0.frame.origin.y = _stackContentRect.maxY - $0.frame.height }
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
            
        case .fillHeight(let spacing):
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
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        
        return contentSize
    }
    
    open override func sizeToFit() {
        frame.size = sizeThatFits(.zero)
    }
    
    open override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}

extension HStackView {
    
    /// 自动间距
    ///
    /// Z = 在两个 view 之间的 spacer 的数量 ( spacer 的设计是忽略 spacing 的 )
    /// A = 排除所有 spacer
    /// B = frame.width - A.widths
    /// C = B / (A.count - 1 - Z)
    /// C 即是最终结果
    ///
    private func autoSpacing() -> CGFloat {
        let unspacerViews = viewsWithoutSpacer()
        let spacersCount = spacerViews().map({ isSpacerBetweenInTwoViews(spacerView: $0) }).filter({ $0 }).count
        let number = unspacerViews.count - spacersCount - 1
        return (frame.width - viewsWidth() - lengthOfAllFixedLengthSpacer()) / CGFloat(max(1, number))
    }
    
    private func viewsWidth() -> CGFloat {
        viewsWithoutSpacer().map({ $0.frame.width }).reduce(0, +)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, subview) in effectiveSubviews.enumerated() {
            if index == 0 {
                subview.frame.origin.x = _stackContentRect.minX
            } else {
                let previousView = effectiveSubviews[index - 1]
                if (previousView as? SpacerView) != nil || (subview as? SpacerView) != nil { // spacer and view no spacing
                    subview.frame.origin.x = previousView.frame.maxX
                } else {
                    subview.frame.origin.x = previousView.frame.maxX + spacing
                }
            }
        }
    }
    
    private func fillHeight() {
        if frame.height == 0 {
            frame.size.height = contentSize.height
        }
        for subview in effectiveSubviews {
            let oldHeight = subview.frame.height
            subview.frame.size.height = _stackContentWidth
            
            // fix #https://github.com/iWECon/StackKit/issues/21
            guard alignment == .center else {
                continue
            }
            subview.frame.origin.y -= (_stackContentWidth - oldHeight) / 2
        }
    }
    
    private func fillWidth() {
        let maxW = frame.width - lengthOfAllFixedLengthSpacer() - dividerSpecifyLength()
        var w = (maxW) / CGFloat(viewsWithoutSpacerAndDivider().count)
        
        let unspacersView = viewsWithoutSpacerAndDivider()
        w = maxW / CGFloat(unspacersView.count)
        for subview in unspacersView {
            subview.frame.size.width = w
        }
    }
}

// MARK: Divider
extension HStackView {
    
    private func dividerSpecifyLength() -> CGFloat {
        dividerViews()
            .map({ $0.thickness })
            .reduce(0, +)
    }
    
    private func fillDivider() {
        let maxHeight = effectiveSubviews.filter({ ($0 as? DividerView) == nil }).map({ $0.frame.size.height }).max() ?? frame.height
        for divider in effectiveSubviews.compactMap({ $0 as? DividerView }) {
            var maxLength = divider.maxLength
            if maxLength == .greatestFiniteMagnitude {
                // auto
                maxLength = maxHeight
            } else if maxHeight < maxLength {
                maxLength = maxHeight
            }
            divider.frame.size.height = maxLength
        }
    }
    
}

// MARK: Spacer
extension HStackView {
    
    private func fillSpecifySpacer() {
        let spacers = effectiveSubviews.compactMap({ $0 as? SpacerView })
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
        guard unspacerViews.count != effectiveSubviews.count else { return }
        
        // 在 view 与 view 之间的 spacer view 数量: 两个 view 夹一个 spacer view
        let betweenInViewsCount = spacerViews().map({ isSpacerBetweenInTwoViews(spacerView: $0) }).filter({ $0 }).count
        // 非 spacer view 的总宽度
        let unspacerViewsWidth = viewsWidth()
        // 排除 spacer view 后的间距
        let unspacerViewsSpacing: CGFloat
        
        if unspacerViews.count == 1 {
            unspacerViewsSpacing = 0
        } else {
            switch distribution {
            case .spacing(let spacing):
                // 正常 spacing 数量: (views.count - 1), spacer 左右的视图没有间距，所以需要再排除在 view 之间的 spacer 数量
                unspacerViewsSpacing = spacing * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
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
        let spacersWidth = (frame.width - unspacerViewsMaxWidth - self.lengthOfAllFixedLengthSpacer())
        let spacerWidth = spacersWidth / CGFloat(self.dynamicSpacerViews().count)
        
        let spacerViews = self.spacerViews()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerWidth, for: .width)
        }
    }
}
