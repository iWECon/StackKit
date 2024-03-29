//
//  WrapStackDemoViewController.swift
//  Demo
//
//  Created by i on 2022/8/31.
//

import UIKit
import StackKit

class WrapStackDemoViewController: UIViewController {
    
    let fixedWrapStackView = WrapStackView(
        itemSize: .fixed(CGSize(width: 30, height: 30)),
        contentInsets: UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14),
        itemSpacing: 4,
        lineSpacing: 10
    )
    
    let adaptiveWrapStackView = WrapStackView(
        itemSize: .adaptive(column: 6),
        contentInsets: UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14),
        itemSpacing: 10,
        lineSpacing: 4
    )
    
    let autoWrapStackView = WrapStackView(
        itemSize: .auto,
        contentInsets: UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14),
        itemSpacing: 10,
        lineSpacing: 10
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let widths: [CGFloat] = [20, 30, 50, 120, 40, 230, 50, 60, 10]
        fixedWrapStackView.addContent {
            for _ in (0 ... 3) {
                makeUIView().stack.then { $0.frame.size = CGSize(width: widths.randomElement() ?? 10, height: 30) }
            }
        }
        view.addSubview(fixedWrapStackView)
        
        adaptiveWrapStackView.addContent {
            for _ in (0 ... 11) {
                makeUIView().stack.then { $0.frame.size = CGSize(width: widths.randomElement() ?? 10, height: 30) }
            }
        }
        view.addSubview(adaptiveWrapStackView)
        
        autoWrapStackView.addContent {
            for _ in (0 ... 9) {
                makeUIView().stack.then { $0.frame.size = CGSize(width: widths.randomElement() ?? 10, height: 30) }
            }
            makeUIView().stack.size(50, 30)
            makeUIView().stack.size(60, 30)
            makeUIView().stack.size(20, 30)
            makeUIView().stack.size(10, 30)
        }
        view.addSubview(autoWrapStackView)
    }
    
    private func makeUIView() -> UIView {
        let v = UIView()
        let red: CGFloat = CGFloat((0 ... 255).randomElement() ?? 0) / 255
        let green: CGFloat = CGFloat((0 ... 255).randomElement() ?? 0) / 255
        let blue: CGFloat = CGFloat((0 ... 255).randomElement() ?? 0) / 255
        v.backgroundColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1)
        return v
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        fixedWrapStackView.pin.top(120).horizontally().sizeToFit(.content)
        adaptiveWrapStackView.pin.top(to: fixedWrapStackView.edge.bottom).marginTop(50).horizontally().sizeToFit(.width)
        autoWrapStackView.pin.top(to: adaptiveWrapStackView.edge.bottom).marginTop(50).horizontally().sizeToFit(.width)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
