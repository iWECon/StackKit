//
//  File.swift
//  
//
//  Created by bro on 2022/8/3.
//

import UIKit

open class WrapStackLayer: CALayer {
    
    public enum Alignment {
        /// from left to right
        case nature
        
        /// from center to fill
        case center
        
        /// from right to left
        case reversed
    }
    
    public var alignment: Alignment = .center
    public var contentInsets: UIEdgeInsets = .zero
    public var itemSpacing: CGFloat = 0
    public var lineSpacing: CGFloat = 0
    
    open var effectiveSublayers: [CALayer] {
        (sublayers ?? []).lazy.filter { $0._isEffectiveLayer }
    }
    
    public var contentSize: CGSize {
        effectiveSublayers.map({ $0.frame }).reduce(CGRect.zero) { result, rect in
            result.union(rect)
        }.size
    }
    
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
        alignment: Alignment = .center,
        contentInsets: UIEdgeInsets = .zero,
        itemSpacing: CGFloat = 0,
        lineSpacing: CGFloat = 0,
        @_StackKitLayerContentResultBuilder content: () -> [CALayer] = { [] }
    ) {
        super.init()
        
        self.alignment = alignment
        self.contentInsets = contentInsets
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        
        for l in content() {
            addSublayer(l)
        }
    }
    
    open func refreshSublayers() {
        for sublayer in effectiveSublayers {
            sublayer.frame.size = sublayer.preferredFrameSize()
        }
    }
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        
        // TODO: 
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSublayers()
        
        var _size = size
        if size.width == CGFloat.greatestFiniteMagnitude || size.width == 0 {
            _size.width = contentSize.width
        }
        if size.height == CGFloat.greatestFiniteMagnitude || size.height == 0 {
            _size.height = contentSize.height
        }
        return _size
    }
    
    public func sizeToFit() {
        let size = sizeThatFits(.zero)
        self.frame.size = size
    }
}
