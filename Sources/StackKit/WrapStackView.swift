//
//  File.swift
//  
//
//  Created by bro on 2022/8/3.
//

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
        @_StackKitViewContentResultBuilder content: () -> [UIView] = { [] }
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
    
    public var effectiveSubviews: [UIView] {
        subviews.filter { $0.alpha > 0 && !$0.isHidden && $0.frame.size != .zero }
    }
    
    open override func addSubview(_ view: UIView) {
        if let lastViewFrame = effectiveSubviews.last?.frame {
            view.frame.origin = lastViewFrame.origin
        }
        super.addSubview(view)
    }
    
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
            break
            
        case .reverse:
            break
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSubviews()
        
        let effectiveViewsSize = effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
        
        var _size = size
        if size.width == CGFloat.greatestFiniteMagnitude {
            _size.width = effectiveViewsSize.width
        }
        if size.height == CGFloat.greatestFiniteMagnitude {
            _size.height = effectiveViewsSize.height
        }
        
        _size.height += contentInsets.bottom
        return _size
    }
}

extension WrapStackView {
    
    private func itemSize(_ item: UIView) -> CGSize {
        switch itemSize {
        case .adaptive(let column):
            let itemLength = itemSpacing * CGFloat(column - 1)
            let contentHorizontalLength = contentInsets.left + contentInsets.right
            let calculateWidth = (frame.width - contentHorizontalLength - itemLength) / CGFloat(column)
            let calculateSize = CGSize(width: calculateWidth, height: item.frame.height)
            item.frame.size = calculateSize
            return calculateSize
            
        case .fixed(let size):
            item.frame.size = size
            return size
        }
    }
}
