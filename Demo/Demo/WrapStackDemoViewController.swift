//
//  WrapStackDemoViewController.swift
//  Demo
//
//  Created by i on 2022/8/31.
//

import UIKit
import StackKit

class WrapStackDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let vStack = VStackView(distribution: .fillWidth(spacing: 10)) {
            UILabel().stack.then {
                $0.text = "StackKit"
                $0.font = .systemFont(ofSize: 18, weight: .semibold)
                $0.textColor = .black
            }
            Divider()
            UILabel().stack.then {
                $0.text = "Version 1.0.0"
                $0.font = .systemFont(ofSize: 14, weight: .regular)
                $0.textColor = .gray
            }
        }
        vStack.sizeToFit()
        vStack.frame.origin = CGPoint(x: 20, y: 120)
        
        view.addSubview(vStack)
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
