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
    
    open var effectiveSubviews: [UIView] {
        subviews.filter { $0._isEffectiveView }
    }
    
    public var contentSize: CGSize {
        effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
    }
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        if subview.frame.size == .zero {
            subview.sizeToFit()
        }
        
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        switch alignment {
        case .left:
            effectiveSubviews.forEach { $0.frame.origin.x = 0 }
        case .center:
            effectiveSubviews.forEach { $0.center.x = frame.width / 2 }
        case .right:
            effectiveSubviews.forEach { $0.frame.origin.x = frame.width - $0.frame.width }
        }
        
        fillSpacer()
        
        switch distribution {
        case .spacing(let spacing):
            makeSpacing(spacing)
            
        case .autoSpacing:
            let spacing = autoSpacing()
            makeSpacing(spacing)
            
        case .fillWidth:
            let spacing = autoSpacing()
            makeSpacing(spacing)
            fillWidth()
            
        case .fill:
            fillWidth()
            let w = frame.width / CGFloat(effectiveSubviews.count)
            effectiveSubviews.forEach {
                $0.frame.size.width = w
            }
        }
        
        fillDivider()
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
    
    private func fillSpacer() {
        let unspacerViews = subviews.filter({ ($0 as? SpacerView) == nil })
        let betweenInViewsCount = subviews.compactMap({ $0 as? SpacerView }).map({ isSpacerBetweenViews($0) }).filter({ $0 }).count
        let unspacerViewsHeight = unspacerViews.map({ $0.frame.height }).reduce(0, { $0 + $1 })
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
        var spacersHeight = (frame.height - unspacerViewsMaxHeight)
        let spacerHeight = spacersHeight / CGFloat(subviews.count - unspacerViews.count)
        
        let spacerViews = subviews.compactMap({ $0 as? SpacerView })
        let spacerSpecifyViews = spacerViews.filter({ $0.min > .leastNonzeroMagnitude || $0.max < .greatestFiniteMagnitude })
        // 先找出设定了 min 和 max 的 spacer
        // 将高度设定完成后减去 spacersHeight 总高度
        for spacer in spacerSpecifyViews {
            if spacerHeight > spacer.max {
                spacer.frame.size.height = spacer.max
            } else if spacerHeight < spacer.min {
                spacer.frame.size.height = spacer.min
            } else {
                spacer.frame.size.height = spacerHeight
            }
            spacersHeight -= spacer.frame.size.height
        }
        
        // 剩余的高度与没有设定 min 和 max 的 spacer 平分
        let divideHeight = spacersHeight / CGFloat(spacerViews.count - spacerSpecifyViews.count)
        for spacer in spacerViews.filter({ $0.min == .leastNonzeroMagnitude && $0.max == .greatestFiniteMagnitude }) {
            spacer.frame.size.height = divideHeight
        }
    }
    
    private func fillDivider() {
        let maxWidth = subviews.filter({ ($0 as? DividerView) == nil }).map({ $0.frame.size.width }).max() ?? frame.width
        for divider in subviews.compactMap({ $0 as? DividerView }) {
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
    
    private func autoSpacing() -> CGFloat {
        (frame.height - effectiveSubviews.map({ $0.frame.size.height }).reduce(0, { $0 + $1 })) / CGFloat(effectiveSubviews.count)
    }
    
    private func makeSpacing(_ spacing: CGFloat) {
        for (index, sublayer) in effectiveSubviews.enumerated() {
            if index == 0 {
                sublayer.frame.origin.y = 0
            } else {
                let previousLayer = effectiveSubviews[index - 1]
                sublayer.frame.origin.y = previousLayer.frame.maxY + spacing
            }
        }
    }
    
    private func fillWidth() {
        effectiveSubviews.forEach {
            $0.frame.size.width = frame.width
        }
    }
}
