//
//  HVStackWrapperViewDemoViewController.swift
//  Demo
//
//  Created by i on 2022/9/28.
//

import UIKit
import StackKit

let contentWidth: CGFloat = UIScreen.main.bounds.width - 32

class HVStackWrapperViewDemoViewController: UIViewController {
    
    let content = VStackLayerWrapperView {
        HStackLayerWrapperView() {
            VStackLayerWrapperView(alignment: .left) {
                UILabel().stack.then {
                    $0.text = "Good Morning."
                    $0.font = .systemFont(ofSize: 16, weight: .medium)
                    $0.textColor = .gray
                }
                
                UILabel().stack.then {
                    $0.text = "Kukuh Sanjaya"
                    $0.font = .systemFont(ofSize: 20, weight: .bold)
                    $0.textColor = .black
                }
            }
            
            Spacer()
            
            // ICON
            HStackLayerWrapperView(distribution: .spacing(10)) {
                UIView().stack.size(34).then {
                    $0.backgroundColor = .systemPink
                    $0.layer.cornerRadius = 8
                }
                
                UIView().stack.size(34).then {
                    $0.backgroundColor = .systemPink
                    $0.layer.cornerRadius = 8
                }
            }
            
            // wrapper in other view, need set width and sizeToFit
        }.stack.width(contentWidth).sizeToFit(.width)
        
        Spacer(length: 20)
        
        HStackLayerWrapperView {
            HStackLayerWrapperView(distribution: .spacing(6)) {
                UIView().stack.size(60).then {
                    $0.backgroundColor = .systemPink
                    $0.layer.cornerRadius = 8
                }
                VStackLayerWrapperView(alignment: .left) {
                    UILabel().stack.then {
                        $0.text = "Spending"
                        $0.font = .systemFont(ofSize: 18)
                        $0.textColor = .gray
                    }
                    UILabel().stack.then {
                        $0.text = "$980"
                        $0.font = .systemFont(ofSize: 22, weight: .medium)
                        $0.textColor = .black
                    }
                }
            }
            Spacer()
            HStackLayerWrapperView(distribution: .spacing(6)) {
                UIView().stack.size(60).then {
                    $0.backgroundColor = .systemPink
                    $0.layer.cornerRadius = 8
                }
                VStackLayerWrapperView(alignment: .left) {
                    UILabel().stack.then {
                        $0.text = "Income"
                        $0.font = .systemFont(ofSize: 18)
                        $0.textColor = .gray
                    }
                    UILabel().stack.then {
                        $0.text = "$2,860"
                        $0.font = .systemFont(ofSize: 22, weight: .medium)
                        $0.textColor = .black
                    }
                }
            }
        }.stack.width(contentWidth).sizeToFit(.width)
        
        Spacer(length: 30)
        HStackLayerWrapperView(alignment: .bottom) {
            UILabel().stack.then {
                $0.text = "Transactions"
                $0.font = .systemFont(ofSize: 24, weight: .bold)
                $0.textColor = .black
            }
            Spacer()
            UILabel().stack.then {
                $0.text = "See All"
                $0.font = .systemFont(ofSize: 18, weight: .medium)
                $0.textColor = .blue
            }
        }.stack.width(contentWidth).sizeToFit(.width)
        
        Spacer(length: 20)
        VStackLayerWrapperView(alignment: .left) {
            
            HStackLayerWrapperView {
                UIView().stack.size(40).then {
                    $0.backgroundColor = .systemPink
                    $0.layer.cornerRadius = 12
                }
                Spacer(length: 10)
                VStackLayerWrapperView(alignment: .left) {
                    UILabel().stack.then {
                        $0.text = "Freelance Work"
                        $0.textColor = .black
                        $0.font = .systemFont(ofSize: 16)
                    }
                    UILabel().stack.then {
                        $0.text = "Apr 26"
                        $0.textColor = .gray
                        $0.font = .systemFont(ofSize: 14)
                    }
                }
                Spacer()
                UILabel().stack.then {
                    $0.text = "+$2,600"
                    $0.textColor = .black
                    $0.font = .systemFont(ofSize: 18, weight: .medium)
                }
            }.stack.width(contentWidth).sizeToFit(.width)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.addSubview(content)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        content.pin.top(view.pin.safeArea).horizontally(16).sizeToFit()
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
