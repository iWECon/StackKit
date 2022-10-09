//
//  HVStackDemoViewController.swift
//  Demo
//
//  Created by i on 2022/8/3.
//

import UIKit
import StackKit
import PinLayout

/// Designed for `iPhone 12`
class HVStackDemoViewController: UIViewController {
    
    let content = HStackView {
        Spacer(length: 12)
        
        UIImageView().stack.size(80).then {
            $0.backgroundColor = .red
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
        
        // Support Spacer (Inspired by SwiftUI)
        Spacer()
        
        VStackView {
            UILabel().stack.then { label in
                label.font = .systemFont(ofSize: 14, weight: .semibold)
                label.textColor = .systemGreen
                label.text = "H/VStack in UIKit"
            }
            Spacer(length: 4)
            Divider(color: UIColor.blue)
            Spacer(length: 12)
            UILabel().stack.then { label in
                label.font = .systemFont(ofSize: 12, weight: .regular)
                label.textColor = .gray
                label.text = "May be the best ~"
            }
        }
        
        Spacer()
        
        VStackView(distribution: .fillWidth(10)) {
            
            // view.stack.then (Inspired by Then [ https://github.com/devxoul/Then ])
            UILabel().stack.then { label in
                label.text = "StackKit"
                label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                label.textColor = .red
            }
            
//            Spacer(length: 6)
            // Support Divider (Inspired by SwiftUI)
            Divider(color: UIColor.orange)
            
//            Spacer(length: 6)
            
            UILabel().stack.then { label in
                label.text = "Version: 1"
                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label.textColor = .gray
            }
        }
        
        Spacer(length: 12)
    }
    
    let vContent = VStackView(alignment: .left, distribution: .spacing(14)) {
        Spacer(length: 12)
        
        HStackView(alignment: .top) {
            Spacer(length: 12)
            
            VStackView {
                Spacer(length: 6)
                UIView().stack.size(6).then {
                    $0.backgroundColor = .systemBlue
                    $0.layer.cornerRadius = 3
                    $0.clipsToBounds = true
                }
            }
            
            Spacer(length: 4)
            UILabel().stack.then {
                $0.textColor = .darkText
                $0.numberOfLines = 0
                $0.text = "Simple grammar\n简单的语法\n一看就懂 一用就会，与 SwiftUI 保持一致"
                $0.font = .systemFont(ofSize: 16, weight: .semibold)
            }
        }
        
        HStackView(alignment: .top, distribution: .spacing(14)) {
            Spacer(length: 12)
            
            VStackView {
                Spacer(length: 6)
                UIView().stack.size(6).then {
                    $0.backgroundColor = .systemBlue
                    $0.layer.cornerRadius = 3
                    $0.clipsToBounds = true
                }
            }
            
            Spacer(length: 4)
            UILabel().stack.then {
                $0.textColor = .darkText
                $0.font = .systemFont(ofSize: 16, weight: .semibold)
                $0.numberOfLines = 0
                $0.text = "Support `Spacer` and `Divider`\n支持 Spacer 与 Divider，与 SwiftUI 保持一致"
            }
        }
        
        HStackView(alignment: .top, distribution: .spacing(14)) {
            Spacer(length: 12)
            
            VStackView {
                Spacer(length: 6)
                UIView().stack.size(6).then {
                    $0.backgroundColor = .systemBlue
                    $0.layer.cornerRadius = 3
                    $0.clipsToBounds = true
                }
            }
            
            Spacer(length: 4)
            UILabel().stack.then {
                $0.textColor = .darkText
                $0.font = .systemFont(ofSize: 16, weight: .semibold)
                $0.numberOfLines = 0
                $0.text = "Support AutoLayout\n支持 Auto layout"
            }
        }
        
        HStackView(alignment: .top, distribution: .spacing(14)) {
            Spacer(length: 12)
            
            VStackView {
                Spacer(length: 6)
                UIView().stack.size(6).then {
                    $0.backgroundColor = .systemBlue
                    $0.layer.cornerRadius = 3
                    $0.clipsToBounds = true
                }
            }
            
            Spacer(length: 4)
            UILabel().stack.then {
                $0.textColor = .darkText
                $0.font = .systemFont(ofSize: 16, weight: .semibold)
                $0.numberOfLines = 0
                $0.text = "⚠️ In development: Relative layout\n相对布局暂不支持，正在开发中"
            }
        }
        
        Spacer(length: 12)
    }
    
    let descriptionContent = VStackView {
        Spacer(length: 12)
        HStackView {
            Spacer(length: 12)
            
            VStackView(alignment: .left, distribution: .spacing(24)) {
                UILabel().stack.then {
                    $0.font = .systemFont(ofSize: 20, weight: .semibold)
                    $0.text = "⚠️ Important"
                }
                UILabel().stack.maxWidth(UIScreen.main.bounds.width - 48).then {
                    $0.textColor = .systemPink
                    $0.font = .systemFont(ofSize: 14, weight: .medium)
                    $0.numberOfLines = 0
                    $0.text = "`Spacer` will ignore the given spacing in H/VStack\nSpacer 会忽略在 H/VStack 中给定的 spacing, 也就是说可以使用 Spacer 自由调整 spacing"
                }
                
                UILabel().stack.then {
                    $0.textColor = .systemPink
                    $0.font = .systemFont(ofSize: 14, weight: .medium)
                    $0.numberOfLines = 0
                    $0.text = "Do not support relative layout for the time being\n暂不支持相对布局（正在开发中）"
                }
                
                // specify `.maxWidth`
                UILabel().stack.maxWidth(UIScreen.main.bounds.width - 48).then {
                    $0.textColor = .systemPink
                    $0.font = .systemFont(ofSize: 14, weight: .medium)
                    $0.numberOfLines = 0
                    $0.text = "The subview may exceed the width/height of the parent view, and you need to specify the maximum width/height manually, add .maxWidth/.maxHeight after `.stack`\n子视图可能超过父视图的宽高，此时需要你手动设定最大宽度或最大高度"
                }
            }
        }
        Spacer(length: 12)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        
        vContent.backgroundColor = .white
        vContent.layer.cornerRadius = 6
        
        descriptionContent.backgroundColor = .white
        descriptionContent.layer.cornerRadius = 6
        
        view.addSubview(content)
        view.addSubview(vContent)
        view.addSubview(descriptionContent)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        content.pin.top(120).horizontally().sizeToFit(.width)
        vContent.pin.below(of: content).horizontally(12).marginTop(20).sizeToFit(.width)
        descriptionContent.pin.below(of: vContent).horizontally(12).marginTop(20).sizeToFit(.width)
    }
}
