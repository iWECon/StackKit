import UIKit

open class VStackView: UIView {
    
    public var alignment: VStackAlignment = .center
    public var distribution: VStackDistribution = .autoSpacing
    
    public required init(
        alignment: VStackAlignment = .center,
        distribution: VStackDistribution = .autoSpacing,
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
        effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
    }
    
    open func hideIfNoEffectiveViews() {
        self.isHidden = effectiveSubviews.isEmpty
    }
    
    private func tryResizeStackView() {
        subviews.forEach { fitSize in
            fitSize._fitSize(with: fitSize.stackKitFitType)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        tryResizeStackView()
        
        switch alignment {
        case .left:
            effectiveSubviews.forEach { $0.frame.origin.x = 0 }
        case .center:
            effectiveSubviews.forEach { $0.center.x = frame.width / 2 }
        case .right:
            effectiveSubviews.forEach { $0.frame.origin.x = frame.width - $0.frame.width }
        }
        
        switch distribution {
        case .spacing(let spacing):
            fillDivider()
            fillSpacer()
            
            makeSpacing(spacing)
            
        case .autoSpacing:
            fillDivider()
            fillSpacer()
            
            let spacing = autoSpacing()
            makeSpacing(spacing)
            
        case .fillWidth:
            fillDivider()
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
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSubviews()
        
        var _size = size
        if size.width == CGFloat.greatestFiniteMagnitude || size.width == 0 {
            _size.width = contentSize.width
        }
        if size.height == CGFloat.greatestFiniteMagnitude || size.height == 0 {
            _size.height = contentSize.height
        }
        return _size
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
        if number <= 0 {
            return 0
        }
        return (frame.height - viewsHeight() - spacerSpecifyLength()) / CGFloat( number)
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
        effectiveSubviews.forEach {
            $0.frame.size.width = frame.width
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
                unspacerViewsSpacing = spacing * CGFloat(unspacerViews.count - betweenInViewsCount - 1) // 正常 spacing 数量: (views.count - 1), spacer 左右的视图没有间距，所以需要再排除在 view 之间的 spacer 数量
                
            case .autoSpacing, .fillWidth:
                unspacerViewsSpacing = autoSpacing() * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fill:
                unspacerViewsSpacing = 0
            }
        }
        
        
        // 非 spacerView 的所有宽度
        let unspacerViewsMaxHeight = unspacerViewsHeight + unspacerViewsSpacing
        let spacersHeight = (frame.height - unspacerViewsMaxHeight)
        let spacerHeight = spacersHeight / CGFloat(self.spacerViews().count)
        
        let spacerViews = self.spacerViews()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerHeight, for: .height)
        }
    }
}
