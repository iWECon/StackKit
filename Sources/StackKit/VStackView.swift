import UIKit

open class VStackView: UIView {
    
    public var alignment: VStackAlignment = .center
    public var distribution: VStackDistribution = .autoSpacing
    
    public required init(
        alignment: VStackAlignment = .center,
        distribution: VStackDistribution = .spacing(2),
        @_StackKitVStackContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        
        self.alignment = alignment
        self.distribution = distribution
        
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
        }.height
        let w = effectiveSubviews.map({ $0.bounds }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.width
        return CGSize(width: w, height: h)
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
            effectiveSubviews.forEach { $0.frame.origin.x = 0 }
        case .center:
            effectiveSubviews.forEach { $0.center.x = frame.width / 2 }
        case .right:
            effectiveSubviews.forEach { $0.frame.origin.x = frame.width - $0.frame.width }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        tryResizeStackView()
        
        makeSubviewsAlignment()
        
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
            
        case .fillWidth(let spacing):
            fillDivider()
            fillSpecifySpacer()
            fillSpacer()
            
            let spacing = spacing ?? autoSpacing()
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

extension VStackView {
    
    private func spacerViews() -> [SpacerView] {
        effectiveSubviews.compactMap({ $0 as? SpacerView })
    }
    private func dynamicSpacerViews() -> [SpacerView] {
        effectiveSubviews.compactMap({ $0 as? SpacerView }).filter({ $0.length == .greatestFiniteMagnitude })
    }
    private func dividerViews() -> [DividerView] {
        effectiveSubviews.compactMap({ $0 as? DividerView })
    }
    
    private func viewsWithoutSpacer() -> [UIView] {
        effectiveSubviews.filter({ ($0 as? SpacerView) == nil })
    }
    private func viewsWithoutSpacerAndDivider() -> [UIView] {
        effectiveSubviews.filter({ ($0 as? SpacerView) == nil && ($0 as? DividerView) == nil })
    }
}

extension VStackView {
    
    /// 自动间距
    ///
    /// Z = 在两个 view 之间的 spacer 的数量 ( spacer 的设计是忽略 spacing 的 )
    /// A = 排除所有 spacer
    /// B = frame.height - A.heights
    /// C = B / (A.count - 1 - Z)
    /// C 即是最终结果
    ///
    private func autoSpacing() -> CGFloat {
        let unspacerViews = viewsWithoutSpacer()
        let spacersCount = spacerViews().map({ isSpacerBetweenViews($0) }).filter({ $0 }).count
        let number = unspacerViews.count - spacersCount - 1
        return (frame.height - viewsHeight() - spacerSpecifyLength()) / CGFloat(max(1, number))
    }
    
    private func viewsHeight() -> CGFloat {
        viewsWithoutSpacer().map({ $0.frame.height }).reduce(0, +)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, subview) in effectiveSubviews.enumerated() {
            if index == 0 {
                subview.frame.origin.y = 0
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
            let oldWidth = subview.frame.width
            subview.frame.size.width = frame.width
            
            // fix #https://github.com/iWECon/StackKit/issues/21
            guard alignment == .center else {
                continue
            }
            subview.frame.origin.x -= (frame.width - oldWidth) / 2
        }
    }
    
    ///
    /// 填充高度, 所有视图（排除 spacer）高度一致
    private func fillHeight() {
        let maxH = frame.height - spacerSpecifyLength() - dividerSpecifyLength()
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
    
    private func dividerSpecifyLength() -> CGFloat {
        dividerViews()
            .map({ $0.thickness })
            .reduce(0, +)
    }
    
    private func fillDivider() {
        let maxWidth = effectiveSubviews.filter({ ($0 as? DividerView) == nil }).map({ $0.frame.size.width }).max() ?? frame.width
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
    
    // 取出固定 length 的 spacer
    private func spacerSpecifyLength() -> CGFloat {
        spacerViews()
            .map({ $0.setLength })
            .reduce(0, +)
    }
    
    private func isSpacerBetweenViews(_ spacer: SpacerView) -> Bool {
        guard let index = effectiveSubviews.firstIndex(of: spacer) else {
            return false
        }
        
        guard effectiveSubviews.count >= 3 else {
            return false
        }
        
        let start: Int = 1
        let end: Int = effectiveSubviews.count - 2
        return (start ... end).contains(index)
    }
    
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
        let betweenInViewsCount = spacerViews().map({ isSpacerBetweenViews($0) }).filter({ $0 }).count
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
        let spacersHeight = (frame.height - unspacerViewsMaxHeight - self.spacerSpecifyLength())
        let spacerHeight = spacersHeight / CGFloat(self.dynamicSpacerViews().count)
        
        let spacerViews = self.spacerViews()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerHeight, for: .height)
        }
    }
}
