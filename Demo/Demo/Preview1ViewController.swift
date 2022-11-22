//
//  Preview1ViewController.swift
//  Demo
//
//  Created by i on 2022/11/20.
//

import UIKit
import StackKit
import Combine

class Preview1ViewController: UIViewController {
    
    let logoView = UIImageView()
    let nameLabel = UILabel()
    let briefLabel = UILabel()
    
    let container = HStackView(alignment: .center)
    
    @Published var name = "iWECon/StackKit"
    @Published var brief = "The best way to use HStack and VStack in UIKit, and also supports Spacer and Divider."
    
    var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        logoView.layer.cornerRadius = 16
        logoView.layer.cornerCurve = .continuous
        logoView.backgroundColor = .systemGroupedBackground
        
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = .black
        
        briefLabel.text = brief
        briefLabel.font = .systemFont(ofSize: 12, weight: .light)
        briefLabel.textColor = .black
        briefLabel.numberOfLines = 0
        
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.black.cgColor
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        
        container.padding = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        container.distribution = .spacing(14) // or use `Spacer(length: 14)`
        
        container.addContent {
            logoView.stack.size(80)
            VStackView(alignment: .left, distribution: .spacing(6)) {
                nameLabel.stack
                    .receive(text: $name, storeIn: &cancellables)
                
                briefLabel.stack.maxWidth(220)
                    .receive(text: $brief, storeIn: &cancellables)
            }
        }
        
        self.view.addSubview(container)
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
            print("done")
            self.name = "StackKit design by iWECon"
            self.brief = "Yes!!!"
            self.container.setNeedsLayout()
        }
        
        DispatchQueue.global().asyncAfter(wallDeadline: .now() + 5) {
            self.name = "StackKit design by iWECon1"
            self.brief = "Yes!!!2"
            DispatchQueue.main.async {
                self.container.setNeedsLayout()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // or use `AutoLayout`
        container.pin.vCenter().hCenter().sizeToFit()
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
