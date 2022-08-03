//
//  File.swift
//  
//
//  Created by bro on 2022/8/3.
//

import UIKit

open class WrapStackView: UIView {
    
    public enum VerticalAlignment {
        case nature
        case center
        case reverse
    }
    
    public enum HorizontalAlignment {
        case top
        case center
        case bottom
    }
    
    public var verticalAlignment: VerticalAlignment = .nature
    public var horizontalAlignment: HorizontalAlignment = .center
    public var contentInsets: UIEdgeInsets = .zero
    public var itemSpacing: CGFloat = 0
    public var lineSpacing: CGFloat = 0
    
    public required init(
        verticalAlignment: VerticalAlignment = .nature,
        horizontalAlignment: HorizontalAlignment = .center,
        contentInsets: UIEdgeInsets = .zero,
        itemSpacing: CGFloat = 0,
        lineSpacing: CGFloat = 0,
        @_StackKitViewContentResultBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        switch verticalAlignment {
        case .nature:
            for (index, subview) in effectiveSubviews.enumerated() {
                guard index != 0 else { // index: 0
                    subview.frame.origin.x = 0
                    continue
                }
                
                let previousView = effectiveSubviews[index - 1]
                let x = previousView.frame.maxX + itemSpacing
                let maxX = x + subview.frame.width
                if maxX > frame.width { // TODO: contentInsets
                    // new section
                    subview.frame.origin.x = 0
                    
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
        
        // TODO: contentInsets
        return effectiveSubviews.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
    }
}
