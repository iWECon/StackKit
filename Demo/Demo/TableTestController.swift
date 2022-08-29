//
//  TableTestController.swift
//  TestStackKit
//
//  Created by i on 2022/8/14.
//

import UIKit
import StackKit

struct User {
    var name: String
    var brief: String
}

final class TableTestController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        
        let names = "梦琪、 忆柳、 之桃、 慕青、 问兰、 尔岚、 元香、 初夏、 沛菡、 傲珊、曼文、 乐菱、 痴珊、 恨玉、 惜文、 香寒、 新柔、 语蓉".components(separatedBy: "、 ")
        let briefs = ["本人性格内外结合，适应能力强，为人诚实，有良好的人际交往能力，具备相关的专业知识和认真。细心、耐心的工作态度及良好的职业道德修养。相信团体精...",
        "我的理念是：在年轻的季节我甘愿吃苦受累，只愿通过自己富有激情、积极主动的努力实现自身价值并在工作中做出的贡献：作为初学者，我具备出色的学习能...",
        "如果有幸能进入贵公司，我会保持“一荣俱荣，永争第一”的企业精神，全身心的工作，为企业创造利益，希望领导考虑我，谢谢！",
                      "自我介绍文案精选我是一名应届师范毕业生，在校是一名优秀学生，我是一个乐观向上拥有梦想的青年，性格活泼开朗，稳重成熟的外表下，充溢着内心的细心..."]
        
        var randomGenerator = SystemRandomNumberGenerator()
        for _ in (0 ... 9) {
            let name = names.randomElement(using: &randomGenerator) ?? "????"
            let brief = briefs.randomElement(using: &randomGenerator) ?? "----"
            users.append(User(name: name, brief: brief))
        }
    }
}

extension TableTestController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? Cell else {
            fatalError()
        }
        let user = users[indexPath.row]
        cell.bind(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        220
    }
}

final class Cell: UITableViewCell {
    
    let nameLabel = UILabel()
    let briefLabel = UILabel()
    let container = VStackView(alignment: .left, distribution: .spacing(8))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.font = .systemFont(ofSize: 18, weight: .medium)
        nameLabel.textColor = .darkText
        
        briefLabel.font = .systemFont(ofSize: 14, weight: .regular)
        briefLabel.textColor = .darkGray
        briefLabel.numberOfLines = 0
        
        container.addContent {
            nameLabel.stack.maxWidth(80).sizeToFit(.height)
            briefLabel.stack.maxWidth(300).sizeToFit(.height)
        }
        
        contentView.addSubview(container)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        container.pin.left(16).vCenter().sizeToFit()
    }
    
    func bind(user: User) {
        defer {
            setNeedsLayout()
            layoutIfNeeded()
            
            print(self.nameLabel.text!, ":", self.contentView.center.y, container.center.y)
        }
        self.nameLabel.text = user.name
        self.briefLabel.text = user.brief
    }
}
