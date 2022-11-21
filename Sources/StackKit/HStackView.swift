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
        
        addContent(content)
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
        let width = effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero, { $0.union($1) }).width
        let height = effectiveSubviews.map({ $0.bounds.height }).max() ?? 0
        
        let offsetXLength = effectiveSubviews.map({ $0.frame.minX }).filter({ $0 < 0 }).min() ?? 0
        return CGSize(width: width + paddingRight + offsetXLength, height: height + paddingVertically)
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
        case .top:
            effectiveSubviews.forEach { $0.frame.origin.y = _stackContentRect.minY }
        case .center:
            effectiveSubviews.forEach { $0.center.y = _stackContentRect.midY }
        case .bottom:
            effectiveSubviews.forEach { $0.frame.origin.y = _stackContentRect.maxY - $0.frame.height }
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
            
        case .fillHeight(let spacing):
            let spacing = spacing ?? autoSpacing()
            makeSpacing(spacing)
            fillHeight()
            
        case .fill:
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
        _fitSize(with: self._stackKit_fitType)
    }
    
    open override var intrinsicContentSize: CGSize {
        sizeThatFits(.zero)
    }
}

extension HStackView {
    
    private func autoSpacing() -> CGFloat {
        let unspacerViews = viewsWithoutSpacer()
        let spacersCount = spacerViews().map({ isSpacerBetweenInTwoViews(spacerView: $0) }).filter({ $0 }).count
        let number = unspacerViews.count - spacersCount - 1
        return (_stackContentRect.width - viewsWidth() - lengthOfAllFixedLengthSpacer()) / CGFloat(max(1, number))
    }
    
    private func viewsWidth() -> CGFloat {
        viewsWithoutSpacer().map({ $0.frame.width }).reduce(0, +)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, subview) in effectiveSubviews.enumerated() {
            if index == 0 {
                subview.frame.origin.x = paddingLeft
            } else {
                let previousView = effectiveSubviews[index - 1]
                if (previousView as? SpacerView) != nil || (subview as? SpacerView) != nil { // spacer and view no spacing
                    subview.frame.origin.x = previousView.frame.maxX
                } else {
                    subview.frame.origin.x = previousView.frame.maxX + spacing
                }
            }
            
            if let offsetX = subview._stackKit_offsetX {
                subview.frame.origin.x += offsetX
            }
            if let offsetY = subview._stackKit_offsetY {
                subview.frame.origin.y += offsetY
            }
        }
    }
    
    private func fillHeight() {
        if frame.height == 0 {
            frame.size.height = contentSize.height
        }
        for subview in effectiveSubviews {
            subview.frame.size.height = _stackContentHeight
            
            // fix #https://github.com/iWECon/StackKit/issues/21
            guard alignment == .center else {
                continue
            }
            subview.center.y = _stackContentRect.midY
        }
    }
    
    private func fillWidth() {
        let maxW = _stackContentRect.width - lengthOfAllFixedLengthSpacer() - lengthOfAllFixedLengthDivider()
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
    
    private func fillDivider() {
        let maxHeight = effectiveSubviews.filter({ ($0 as? DividerView) == nil }).map({ $0.frame.size.height }).max() ?? _stackContentRect.height
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
    
    private func fillSpacer() {
        let unspacerViews = viewsWithoutSpacer()
        guard unspacerViews.count != effectiveSubviews.count else { return }
        
        let betweenInViewsCount = spacerViews().map({ isSpacerBetweenInTwoViews(spacerView: $0) }).filter({ $0 }).count
        
        let unspacerViewsWidth = viewsWidth()
        
        let unspacerViewsSpacing: CGFloat
        
        if unspacerViews.count == 1 {
            unspacerViewsSpacing = 0
        } else {
            switch distribution {
            case .spacing(let spacing):
                unspacerViewsSpacing = spacing * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fillHeight(let spacing):
                unspacerViewsSpacing = (spacing ?? autoSpacing()) * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .autoSpacing:
                unspacerViewsSpacing = autoSpacing() * CGFloat(unspacerViews.count - betweenInViewsCount - 1)
                
            case .fill:
                unspacerViewsSpacing = 0
            }
        }
        
        let unspacerViewsMaxWidth = unspacerViewsWidth + unspacerViewsSpacing
        let spacersWidth = (_stackContentWidth - unspacerViewsMaxWidth - self.lengthOfAllFixedLengthSpacer())
        let spacerWidth = spacersWidth / CGFloat(self.dynamicSpacerViews().count)
        
        let spacerViews = self.spacerViews()
        for spacer in spacerViews {
            spacer.fitSize(value: spacerWidth, for: .width)
        }
    }
}
