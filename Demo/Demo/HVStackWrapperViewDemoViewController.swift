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
    
    let content = VStackView(distribution: .fillWidth(spacing: 0), padding: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)) {
        HStackView() {
            VStackView(alignment: .left) {
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
            HStackView(distribution: .spacing(10)) {
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
        }
        
        Spacer(length: 20)
        
        HStackView {
            HStackView(distribution: .spacing(6)) {
                UIView().stack.size(60).then {
                    $0.backgroundColor = .systemPink
                    $0.layer.cornerRadius = 8
                }
                VStackView(alignment: .left) {
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
            HStackView(distribution: .spacing(6)) {
                UIView().stack.size(60).then {
                    $0.backgroundColor = .systemPink
                    $0.layer.cornerRadius = 8
                }
                VStackView(alignment: .left) {
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
        }
        
        Spacer(length: 30)
        HStackView(alignment: .bottom) {
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
        }.stack.sizeToFit(.width)
        
        Spacer(length: 20)
        
        VStackView(distribution: .fillWidth()) {
            HStackView {
                UIView().stack.size(40).then {
                    $0.backgroundColor = .systemPink
                    $0.layer.cornerRadius = 12
                }
                Spacer(length: 10)
                VStackView(alignment: .left) {
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
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(content)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        content.pin.top(view.pin.safeArea).horizontally().sizeToFit(.width)
    }
    
}
