//
//  VStackLayerContainerView.swift
//  
//
//  Created by i on 2022/10/9.
//

import UIKit

open class VStackLayerContainerView: UIView {
    
    public var vStackLayer: VStackLayer {
        self.layer as! VStackLayer
    }
    
    open var alignment: VStackAlignment {
        get {
            vStackLayer.alignment
        }
        set {
            vStackLayer.alignment = newValue
        }
    }
    
    open var distribution: VStackDistribution {
        get {
            vStackLayer.distribution
        }
        set {
            vStackLayer.distribution = newValue
        }
    }
    
    public required init(
        alignment: VStackAlignment = .center,
        distribution: VStackDistribution = .spacing(2),
        padding: UIEdgeInsets = .zero,
        @_StackKitVStackLayerContentResultBuilder content: () -> [CALayer] = { [] }
    ) {
        super.init(frame: .zero)
        vStackLayer.alignment = alignment
        vStackLayer.distribution = distribution
        vStackLayer.padding = padding
        
        for v in content() {
            vStackLayer.addSublayer(v)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override class var layerClass: AnyClass {
        VStackLayer.self
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        vStackLayer.sizeThatFits(size)
    }
    
    open override func sizeToFit() {
        vStackLayer.sizeToFit()
    }
    
    open func addContent(@_StackKitVStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        vStackLayer.addContent(content)
    }
    
    open func resetContent(@_StackKitVStackLayerContentResultBuilder _ content: () -> [CALayer]) {
        vStackLayer.resetContent(content)
    }
    
    @available(*, deprecated, message: "use `addContent(_:)` or `resetContent(_:)` instead")
    open override func addSubview(_ view: UIView) {
        // deprecated
    }
    
}
