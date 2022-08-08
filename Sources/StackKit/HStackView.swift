import UIKit

open class HStackView: UIView {
    
    public var alignment: HStackAlignment = .center
    public var distribution: HStackDistribution = .autoSpacing
    
    public required init(
        alignment: HStackAlignment = .center,
        distribution: HStackDistribution = .autoSpacing,
        @_StackKitHStackContentResultBuilder content: () -> [UIView] = { [] }
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        switch alignment {
        case .top:
            effectiveSubviews.forEach { $0.frame.origin.y = 0 }
        case .center:
            effectiveSubviews.forEach { $0.center.y = frame.height / 2 }
        case .bottom:
            effectiveSubviews.forEach { $0.frame.origin.y = frame.height - $0.frame.height }
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
            
        case .fillHeight:
            fillDivider()
            fillSpacer()
            
            let spacing = autoSpacing()
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

extension HStackView {
    
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
        let spacersCount = spacerViews().map({ isSpacerBetweenViews($0) }).filter({ $0 }).count
        return viewsWidth() / CGFloat(unspacerViews.count - spacersCount - 1)
    }
    
    private func viewsWidth() -> CGFloat {
        viewsWithoutSpacer().map({ $0.frame.width }).reduce(0, +)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, subview) in effectiveSubviews.enumerated() {
            if index == 0 {
                subview.frame.origin.x = 0
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
        effectiveSubviews.forEach {
            $0.frame.size.height = frame.height
        }
    }
    
    private func fillWidth() {
        let maxW = frame.width - spacerSpecifyLength() - dividerSpecifyLength()
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
    
    // 取出固定 length 的 spacer
    private func spacerSpecifyLength() -> CGFloat {
        spacerViews()
            .map({ $0.setLength })
            .reduce(0, +)
    }
    
    private func isSpacerBetweenViews(_ spacer: SpacerView) -> Bool {
        guard let index = subviews.firstIndex(of: spacer) else {
            return false
        }
        
        var isPreviousView = false
        var isNextView = false
        
        let previous = index - 1
        if previous > 0, previous < subviews.count - 1 {
            isPreviousView = true
        }
        
        let next = index + 1
        if next < subviews.count - 1 {
            isNextView = true
        }
        return isPreviousView && isNextView
    }
    
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
        let betweenInViewsCount = spacerViews().map({ isSpacerBetweenViews($0) }).filter({ $0 }).count
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
                
            case .autoSpacing, .fillHeight:
                unspacerViewsSpacing = autoSpacing() * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fill:
                unspacerViewsSpacing = 0
            }
        }
        
        // 非 spacerView 的所有宽度
        let unspacerViewsMaxWidth = unspacerViewsWidth + unspacerViewsSpacing
        let spacersWidth = (frame.width - unspacerViewsMaxWidth)
        let spacerWidth = spacersWidth / CGFloat(self.spacerViews().count)
        
        let spacerViews = self.spacerViews()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerWidth, for: .width)
        }
    }
}
