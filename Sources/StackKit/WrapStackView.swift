import UIKit

open class WrapStackView: UIView {
    
    public var verticalAlignment: WrapStackVerticalAlignment = .nature
    public var horizontalAlignment: WrapStackHorizontalAlignment = .center
    public var contentInsets: UIEdgeInsets = .zero
    public var itemSpacing: CGFloat = 0
    public var lineSpacing: CGFloat = 0
    public var itemSize: WrapStackItemSize = .adaptive(column: 4)
    
    public required init(
        verticalAlignment: WrapStackVerticalAlignment = .nature,
        horizontalAlignment: WrapStackHorizontalAlignment = .center,
        itemSize: WrapStackItemSize = .adaptive(column: 4),
        contentInsets: UIEdgeInsets = .zero,
        itemSpacing: CGFloat = 0,
        lineSpacing: CGFloat = 0,
        @_StackKitWrapStackContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.itemSize = itemSize
        self.contentInsets = contentInsets
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        
        for v in content() {
            addSubview(v)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func addContent(@_StackKitWrapStackContentResultBuilder _ content: () -> [UIView]) {
        for v in content() {
            addSubview(v)
        }
    }
    
    public func resetContent(@_StackKitWrapStackContentResultBuilder _ content: () -> [UIView]) {
        subviews.forEach { $0.removeFromSuperview() }
        for v in content() {
            addSubview(v)
        }
    }
    
    public var effectiveSubviews: [UIView] {
        subviews.filter { $0._isEffectiveView }
    }
    
    private class Attribute: Equatable {
        var section: Int  // 第几行
        var subviews: [UIView] = []
        var hStackView: HStackView = HStackView()
        
        required init(section: Int) {
            self.section = section
        }
        
        static func == (lhs: Attribute, rhs: Attribute) -> Bool {
            lhs.section == rhs.section
        }
    }
    private var attributes: [Attribute] = []
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        switch verticalAlignment {
        case .nature:
            for (index, subview) in effectiveSubviews.enumerated() {
                
                let subviewSize = itemSize(subview)
                
                guard index != 0 else { // index: 0
                    // contentInsets
                    subview.frame.origin.x = contentInsets.left
                    subview.frame.origin.y = contentInsets.top
                    continue
                }
                
                let previousView = effectiveSubviews[index - 1]
                
                let x = previousView.frame.maxX + itemSpacing
                let maxX = x + subviewSize.width
                if maxX > frame.width - contentInsets.right {
                    // new section
                    subview.frame.origin.x = contentInsets.left // contentInsets
                    
                    let upMaxY = effectiveSubviews[...(index - 1)].map { $0.frame.maxY }.max() ?? 0
                    subview.frame.origin.y = upMaxY + lineSpacing
                    
                } else {
                    // same section
                    subview.frame.origin.x = x
                    subview.frame.origin.y = previousView.frame.origin.y
                }
            }
            
        case .center:
            let centerX = frame.width / 2
            
            let effectiveSubviews = effectiveSubviews
            
            var section = 0
            for (index, subview) in effectiveSubviews.enumerated() {
                let subviewSize = itemSize(subview)
                
                guard index != 0 else { // index: 0
                    recordAttribute(section: section, subView: subview)
                    
                    let hStackView = hStackView(at: section)
                    addSubview(hStackView)
                    hStackView.center.x = centerX
                    hStackView.frame.origin.y = contentInsets.top
                    continue
                }
                
                let previousView = effectiveSubviews[index - 1]
                let subviewAttribute = attribute(withSubview: previousView)
                let subViewInHStackView = subviewAttribute.hStackView
                let maxX = subViewInHStackView.frame.width + itemSpacing + subviewSize.width
                if maxX >= frame.width - contentInsets.right {
                    // new section
                    section += 1
                    
                    recordAttribute(section: section, subView: subview)
                    
                    let hStackView = hStackView(at: section)
                    addSubview(hStackView)
                    hStackView.center.x = centerX
                    hStackView.frame.origin.y = subViewInHStackView.frame.maxY + lineSpacing
                } else {
                    // same section
                    recordAttribute(section: section, subView: subview)
                    let hStackView = hStackView(at: section)
                    
                    hStackView.center.x = centerX
                }
            }
            moveAllHStackViewSubviewsToSelf()
            
        case .reverse:
            fatalError("`.reverse` is not currently supported")
        }
    }
    
    private func moveAllHStackViewSubviewsToSelf() {
        for attribute in attributes {
            for subview in attribute.subviews {
                let superRect = attribute.hStackView.convert(subview.frame, to: self)
                addSubview(subview)
                subview.frame = superRect
            }
            attribute.subviews.removeAll()
            attribute.hStackView.removeFromSuperview()
        }
        attributes.removeAll()
    }
    
    private func hStackView(at section: Int) -> HStackView {
        guard attributes.contains(where: { $0.section == section }) else {
            return .init()
        }
        return attributes.first(where: { $0.section == section })!.hStackView
    }
    
    private func attribute(withSubview subview: UIView) -> Attribute {
        attributes.lazy.first(where: { $0.subviews.lazy.contains(subview) })!
    }
    
    private func views(inSection section: Int) -> [UIView] {
        guard let attr = attributes.first(where: { $0.section == section }) else {
            return []
        }
        return attr.subviews
    }
    
    private func recordAttribute(section: Int, subView: UIView) {
        if let attr = attributes.first(where: { $0.section == section }) {
            if !attr.subviews.contains(subView) { // contains
                attr.subviews.append(subView)
                attr.hStackView.addSubview(subView)
                
                attr.hStackView.frame.size.height = attr.subviews.map({ $0.frame.size.height }).max() ?? 0
                let hStackSize = attr.hStackView.sizeThatFits(.zero)
                attr.hStackView.frame.size = hStackSize
            }
        } else { // no contains (means a new section)
            let attr = Attribute(section: section)
            attr.subviews.append(subView)
            attr.hStackView.distribution = .spacing(itemSpacing)
            switch horizontalAlignment { // set alignment
            case .top:
                attr.hStackView.alignment = .top
            case .center:
                attr.hStackView.alignment = .center
            case .bottom:
                attr.hStackView.alignment = .bottom
            }
            subView.frame.origin = .zero
            attr.hStackView.frame.size = subView.frame.size // first size
            attr.hStackView.addSubview(subView)
            
            let hStackSize = attr.hStackView.sizeThatFits(.zero)
            attr.hStackView.frame.size = hStackSize
            
            attributes.append(attr)
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSubviews()
        let effectiveViewsSize = effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
        
        var _size = effectiveViewsSize
        if !effectiveSubviews.isEmpty {
            _size.height += contentInsets.bottom
        }
        return _size
    }
    
    open override func sizeToFit() {
        layoutSizeToFit(.auto)
    }
    
    public func layoutSizeToFit(_ layout: WrapStackLayout) {
        let size: CGSize
        switch layout {
        case .width(let value):
            let w = value > 0 ? value : frame.width
            size = sizeThatFits(CGSize(width: w, height: CGFloat.greatestFiniteMagnitude))
            
        case .height(let value):
            let h = value > 0 ? value : frame.height
            size = sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: h))
            
        case .fit(let _size):
            size = sizeThatFits(_size)
            
        case .auto:
            size = sizeThatFits(.zero)
        }
        frame.size = size
    }
}

extension WrapStackView {
    
    private func itemSize(_ item: UIView) -> CGSize {
        switch itemSize {
        case .adaptive(let column):
            let itemLength = itemSpacing * CGFloat(column - 1)
            let contentHorizontalLength = contentInsets.left + contentInsets.right
            let calculateWidth = (frame.width - contentHorizontalLength - itemLength) / CGFloat(column)
            // call size to fits
            let itemHeight = item.sizeThatFits(CGSize(width: calculateWidth, height: CGFloat.greatestFiniteMagnitude)).height
            let calculateSize = CGSize(width: calculateWidth, height: itemHeight)
            item.frame.size = calculateSize
            return calculateSize
            
        case .fixed(let size):
            let _ = item.sizeThatFits(size) // call size to fits
            item.frame.size = size
            return size
        }
    }
}
