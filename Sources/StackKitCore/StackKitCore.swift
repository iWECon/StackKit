//
//  File.swift
//  
//
//  Created by i on 2023/7/21.
//

import Foundation


/**
 计算视图位置
 
 protocol Layoutable {
    var view: UIView { get }
    
    var frame: CGRect { get }
    var bounds: CGRect { get }
    var isHidden: Bool { get }
 
    mutating func sizeThatFits(_ size: CGSize) -> CGSize
    mutating func sizeToFit()
 
    func removeFromSuperview()
    func addSubview(_ view: UIView)
 }
 // default implemention
 extension Layoutable {
     //var frame: CGRect { view.frame }
     //var bounds: CGRect { view.bounds }
     var isHidden: Bool { view.isHidden }

//     func sizeThatFits(_ size: CGSize) -> CGSize {
//        view.sizeThatFits(size)
//     }
//     func sizeToFit() {
//        view.sizeToFit()
/     }

     func removeFromSuperview() {
        view.removeFromSuperview()
     }
     func addSubview(_ view: UIView) {
        view.addSubview(view)
     }
 }
 
 // 为 UIView 提供一个绑定操作
 // 当 UIView 隐藏时，Spacer 会同步隐藏 (不会参与到宽高计算中去)
 // 目前的操作需要手动 stackView.resetContent { ... }
 UIView.bind(spacer: Spacer(length: 10))
 
 实际实现应该类似：
    view.stack
        .bind(spacer: Spacer(length: 10), on: .top)
        // or
        .bind(Spacer(length: 10), on: .bottom)
 
 // on: Position
 enum Position {
    /// available on VStackView
    case top, bottom
 
    /// available on HStackView
    case left, right
 
    // or (auto check HStack or VStack)
    case before, after
 }
 
 同时也可以绑定 Divider
    view.stack
        .bind(divider: Divider(thickness: 2), on: .left)
        // or
        .bind(Divider(thickness: 2), on: .right)
 
--> 这个 view 组成
    view.extraSize? 或者其他比较方便识别的
    
    view 的下一个视图去计算位置的时候，需要判断这个 view 额外的 size (Divider.size or Spacer.size)
 
 
 -------------------------------------------------------------
 
 struct LayoutInfo: Layoutable {
    var frame: CGRect
    var bounds: CGRect
 
    var view: UIView
    init(view: UIView) {
        self.view = view
        self.frame = view.frame
        self.bounds = view.bounds
    }
 
    mutating func sizeToFit() {
        view.sizeToFit()
        self.frame = view.frame
    }
    mutating func sizeThatFits(_ size: CGSize) -> CGSize {
        self.frame = view.sizeThatFits(size)
    }
 }
 
 // MARK: Example HStackView
 open class HStackView: UIView {
    
    var laidOuts: [LayoutInfo] = []
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        tryResizeStackView()
 
        makeSpacing(10)
    }
 
    func makeSpacing(_ spacing: CGFloat) {
        
    }
 }
 
 
 
 -----------------------------------------------------------------
 
 layoutInfo1.frame.size = CGSize(width: 10, height: 10)
 layoutInfo2.frame.size = CGSize(width: 10, height: 10)
 
 HStackView {
    frame1
    frame2
 }
 
 layoutInfo1.frame.origin.x = 0
 layoutInfo2.frame.origin.x = frame1.frame.maxX + spacing
 layoutInfo.apply()
 */
