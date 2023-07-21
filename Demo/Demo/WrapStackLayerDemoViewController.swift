//
//  WrapStackLayerDemoViewController.swift
//  Demo
//
//  Created by i on 2023/6/12.
//

import UIKit
import StackKit
import PinLayout

extension WrapStackLayer: SizeCalculable { }

class WrapStackLayerDemoViewController: UIViewController {
    
    let fixedWrapStackLayer = WrapStackLayer(
        itemSize: .fixed(CGSize(width: 30, height: 30)),
        contentInsets: UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14),
        itemSpacing: 4,
        lineSpacing: 10
    )
    
    let adaptiveWrapStackLayer = WrapStackLayer(
        itemSize: .adaptive(column: 6),
        contentInsets: UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14),
        itemSpacing: 10,
        lineSpacing: 4
    )
    
    let autoWrapStackLayer = WrapStackLayer(
        itemSize: .auto,
        contentInsets: UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14),
        itemSpacing: 10,
        lineSpacing: 10
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let widths: [CGFloat] = [20, 30, 50, 120, 40, 230, 50, 60, 10]
        fixedWrapStackLayer.addContent {
            for _ in (0 ... 20) {
                makeUIView(size: CGSize(width: widths.randomElement() ?? 10, height: 30))
            }
        }
        view.layer.addSublayer(fixedWrapStackLayer)
        
        adaptiveWrapStackLayer.addContent {
            for _ in (0 ... 11) {
                makeUIView(size: CGSize(width: widths.randomElement() ?? 10, height: 30))
            }
        }
        view.layer.addSublayer(adaptiveWrapStackLayer)
        
        autoWrapStackLayer.addContent {
            for _ in (0 ... 11) {
                makeUIView(size: CGSize(width: widths.randomElement() ?? 10, height: 30))
            }
        }
        view.layer.addSublayer(autoWrapStackLayer)
    }
    
    private func makeUIView(size: CGSize) -> CALayer {
        let v = CALayer()
        let red: CGFloat = CGFloat((0 ... 255).randomElement() ?? 0) / 255
        let green: CGFloat = CGFloat((0 ... 255).randomElement() ?? 0) / 255
        let blue: CGFloat = CGFloat((0 ... 255).randomElement() ?? 0) / 255
        v.backgroundColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1).cgColor
        v.frame.size = size
        return v
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        fixedWrapStackLayer.pin.top(120).maxWidth(220).sizeToFit(.width)
        adaptiveWrapStackLayer.pin.top(to: fixedWrapStackLayer.edge.bottom).marginTop(50).horizontally().sizeToFit(.width)
        autoWrapStackLayer.pin.top(to: adaptiveWrapStackLayer.edge.bottom).marginTop(50).horizontally().sizeToFit(.width)
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
