# StackKit

☝️ 一个和 SwiftUI 写法类似的布局库。

先看个例子:

// SwiftUI
```swift
HStack(alignment: .leading) {
    Image(named: "")
    VStack {
        Text("SwiftUI")
        Text("Version: 3")
    }
}
```

// StackKit
```swift
HStackView(alignment: .left, distribution: .spacing(14)) {
    UIImageView(image: UIImage(named: ""))

    VStackView {
        // 便捷初始化 需要通过 extension UILabel 自己添加
        UILabel(text: "StackKit", font: .semibold(18), color: .red)
        UILabel(text: "Version: 1", font: .medium(14), color: .gray)
    }
    
}
```

`VStackView` / `HStackView` 可以互相嵌套，尾随闭包使用 `@resultBuilder` 与 `SwiftUI` 保持一致。


emmm... 配图啥的有空的时候我再传，现在自己测试过也在项目里用了，么得问题。



# 安装方式

现在就 SwiftPM，有 Pod 需求的可以提 PR，不然我也懒。因为这个布局都是硬算的，没有用其他第三方，作为独立的库，我觉得 SwiftPM 省事儿。

```swift
.package(url: "https://github.com/iWECon/StackKit.git", from: "1.0.0")
```
