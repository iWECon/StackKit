//
//  HStackLayerContainerView.swift
//  
//
//  Created by i on 2022/10/9.
//

import UIKit

open class HStackLayerContainerView: UIView {
    
    public var hStackLayer: HStackLayer {
        self.layer as! HStackLayer
    }
    
    open var alignment: HStackAlignment {
        get {
            hStackLayer.alignment
        }
        set {
            hStackLayer.alignment = newValue
        }
    }
    
    open var distribution: HStackDistribution {
        get {
            hStackLayer.distribution
        }
        set {
            hStackLayer.distribution = newValue
        }
    }
    
    public required init(
        alignment: HStackAlignment = .center,
        distribution: HStackDistribution = .autoSpacing,
        @_StackKitHStackLayerContentResultBuilder content: () -> [CALayer] = { [] }
    ) {
        super.init(frame: .zero)
        hStackLayer.alignment = alignment
        hStackLayer.distribution = distribution
        
        for v in content() {
            hStackLayer.addSublayer(v)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override class var layerClass: AnyClass {
        HStackLayer.self
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        hStackLayer.sizeThatFits(size)
    }
    
    open func addContent(@_StackKitHStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        hStackLayer.addContent(content)
    }
    
    open func resetContent(@_StackKitHStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        hStackLayer.resetContent(content)
    }
    
    @available(*, deprecated, message: "use `addContent(_:)` or `resetContent(_:)` instead")
    open override func addSubview(_ view: UIView) {
        // deprecated
    }
    
}

