import UIKit

open class WrapStackLayer: CALayer {
    
    public var verticalAlignment: WrapStackVerticalAlignment = .nature
    public var horizontalAlignment: WrapStackHorizontalAlignment = .center
    public var contentInsets: UIEdgeInsets = .zero
    public var itemSpacing: CGFloat = 0
    public var lineSpacing: CGFloat = 0
    public var itemSize: WrapStackItemSize = .adaptive(column: 4)
    
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
        verticalAlignment: WrapStackVerticalAlignment = .nature,
        horizontalAlignment: WrapStackHorizontalAlignment = .center,
        itemSize: WrapStackItemSize = .auto,
        contentInsets: UIEdgeInsets = .zero,
        itemSpacing: CGFloat = 0,
        lineSpacing: CGFloat = 0,
        @_StackKitWrapStackLayerContentResultBuilder content: () -> [CALayer] = { [] }
    ) {
        super.init()
        
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.itemSize = itemSize
        self.contentInsets = contentInsets
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        
        addContent(content)
    }
    
    public func addContent(@_StackKitWrapStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        for v in content() {
            addSublayer(v)
        }
    }
    
    public func resetContent(@_StackKitWrapStackContentResultBuilder _ content: () -> [CALayer]) {
        sublayers?.forEach { $0.removeFromSuperlayer() }
        addContent(content)
    }
    
    public var effectiveSublayers: [CALayer] {
        sublayers?.filter { $0._isEffectiveLayer } ?? []
    }
    
    private class Attribute: Equatable {
        var section: Int  // 第几行
        var subLayers: [CALayer] = []
        var hStackLayer: HStackLayer = HStackLayer()
        
        required init(section: Int) {
            self.section = section
        }
        
        static func == (lhs: Attribute, rhs: Attribute) -> Bool {
            lhs.section == rhs.section
        }
    }
    private var attributes: [Attribute] = []
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        
        switch verticalAlignment {
        case .nature:
            for (index, subview) in effectiveSublayers.enumerated() {
                
                let subviewSize = itemSize(subview)
                
                guard index != 0 else { // index: 0
                    // contentInsets
                    subview.frame.origin.x = contentInsets.left
                    subview.frame.origin.y = contentInsets.top
                    continue
                }
                
                let previousView = effectiveSublayers[index - 1]
                
                let x = previousView.frame.maxX + itemSpacing
                let maxX = x + subviewSize.width
                if maxX > frame.width - contentInsets.right {
                    // new section
                    subview.frame.origin.x = contentInsets.left // contentInsets
                    
                    let upMaxY = effectiveSublayers[...(index - 1)].map { $0.frame.maxY }.max() ?? 0
                    subview.frame.origin.y = upMaxY + lineSpacing
                    
                } else {
                    // same section
                    subview.frame.origin.x = x
                    subview.frame.origin.y = previousView.frame.origin.y
                }
            }
            
        case .center:
            let centerX = frame.width / 2
            
            let effectiveSubviews = effectiveSublayers
            
            var section = 0
            for (index, subview) in effectiveSubviews.enumerated() {
                let subviewSize = itemSize(subview)
                
                guard index != 0 else { // index: 0
                    recordAttribute(section: section, subView: subview)
                    
                    let hStackView = hStackView(at: section)
                    addSublayer(hStackView)
                    hStackView.frame.origin.x = centerX - (hStackView.frame.width / 2)
                    hStackView.frame.origin.y = contentInsets.top
                    continue
                }
                
                let previousView = effectiveSubviews[index - 1]
                let subviewAttribute = attribute(withSubview: previousView)
                let subViewInHStackView = subviewAttribute.hStackLayer
                let maxX = subViewInHStackView.frame.width + itemSpacing + subviewSize.width
                if maxX >= frame.width - contentInsets.right {
                    // new section
                    section += 1
                    
                    recordAttribute(section: section, subView: subview)
                    
                    let hStackView = hStackView(at: section)
                    addSublayer(hStackView)
                    hStackView.frame.origin.x = centerX - (hStackView.frame.width / 2)
                    hStackView.frame.origin.y = subViewInHStackView.frame.maxY + lineSpacing
                } else {
                    // same section
                    recordAttribute(section: section, subView: subview)
                    let hStackView = hStackView(at: section)
                    hStackView.frame.origin.x = centerX - (hStackView.frame.width / 2)
                }
            }
            moveAllHStackViewSubviewsToSelf()
            
        case .reverse:
            fatalError("`.reverse` is not currently supported")
        }
    }
    
    private func moveAllHStackViewSubviewsToSelf() {
        for attribute in attributes {
            for subview in attribute.subLayers {
                let superRect = attribute.hStackLayer.convert(subview.frame, to: self)
                addSublayer(subview)
                subview.frame = superRect
            }
            attribute.subLayers.removeAll()
            attribute.hStackLayer.removeFromSuperlayer()
        }
        attributes.removeAll()
    }
    
    private func hStackView(at section: Int) -> HStackLayer {
        guard attributes.contains(where: { $0.section == section }) else {
            return .init()
        }
        return attributes.first(where: { $0.section == section })!.hStackLayer
    }
    
    private func attribute(withSubview subview: CALayer) -> Attribute {
        attributes.lazy.first(where: { $0.subLayers.lazy.contains(subview) })!
    }
    
    private func views(inSection section: Int) -> [CALayer] {
        guard let attr = attributes.first(where: { $0.section == section }) else {
            return []
        }
        return attr.subLayers
    }
    
    private func recordAttribute(section: Int, subView: CALayer) {
        if let attr = attributes.first(where: { $0.section == section }) {
            if !attr.subLayers.contains(subView) { // contains
                attr.subLayers.append(subView)
                attr.hStackLayer.addSublayer(subView)
                
                attr.hStackLayer.frame.size.height = attr.subLayers.map({ $0.frame.size.height }).max() ?? 0
                let hStackSize = attr.hStackLayer.sizeThatFits(.zero)
                attr.hStackLayer.frame.size = hStackSize
            }
        } else { // no contains (means a new section)
            let attr = Attribute(section: section)
            attr.subLayers.append(subView)
            attr.hStackLayer.distribution = .spacing(itemSpacing)
            switch horizontalAlignment { // set alignment
            case .top:
                attr.hStackLayer.alignment = .top
            case .center:
                attr.hStackLayer.alignment = .center
            case .bottom:
                attr.hStackLayer.alignment = .bottom
            }
            subView.frame.origin = .zero
            attr.hStackLayer.frame.size = subView.frame.size // first size
            attr.hStackLayer.addSublayer(subView)
            
            let hStackSize = attr.hStackLayer.sizeThatFits(.zero)
            attr.hStackLayer.frame.size = hStackSize
            
            attributes.append(attr)
        }
    }
    
    open override func preferredFrameSize() -> CGSize {
        return sizeThatFits(.zero)
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        if size.width != .greatestFiniteMagnitude {
            self.frame.size.width = size.width
        }
        if size.height != .greatestFiniteMagnitude {
            self.frame.size.height = size.height
        }
        self.layoutSublayers()
        
        let effectiveViewsSize = effectiveSublayers.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
        
        var _size = effectiveViewsSize
        if !effectiveSublayers.isEmpty {
            _size.width += contentInsets.right
            _size.height += contentInsets.bottom
        }
        return _size
    }
    
    public func sizeToFit() {
        frame.size = sizeThatFits(.zero)
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

extension WrapStackLayer {
    
    private func itemSize(_ item: CALayer) -> CGSize {
        switch itemSize {
        case .adaptive(let column):
            let itemLength = itemSpacing * CGFloat(column - 1)
            let contentHorizontalLength = contentInsets.left + contentInsets.right
            let calculateWidth = (frame.width - contentHorizontalLength - itemLength) / CGFloat(column)
            // call size to fits
            let itemHeight = (item.frame.size == .zero ? item.preferredFrameSize() : item.frame.size).height
            let calculateSize = CGSize(width: calculateWidth, height: itemHeight)
            item.frame.size = calculateSize
            return calculateSize
            
        case .fixed(let size):
            item.frame.size = size
            return size
            
        case .auto:
            item.frame.size = item.frame.size == .zero ? item.preferredFrameSize() : item.frame.size
            return item.frame.size
        }
    }
}
