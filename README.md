# StackKit

☝️ 一个和 SwiftUI 写法类似的布局库。

先看个例子:

// SwiftUI
```swift
HStack(alignment: .leading) {
    Image(named: "")
    Spacer()
    VStack {
        Text("SwiftUI")
        Divider()
        Text("Version: 3")
    }
}
```

// StackKit
```swift
HStackView(alignment: .left, distribution: .spacing(14)) {
    UIImageView(image: UIImage(named: ""))
    
    Spacer() // 支持 Spacer, 可指定 length 或 min/max

    VStackView {
        // 便捷初始化 需要通过 extension UILabel 自己添加
        UILabel(text: "StackKit", font: .semibold(18), color: .red)
        Divider() // 支持 Divider
        UILabel(text: "Version: 1", font: .medium(14), color: .gray)
    }
    
}


// 视图看起来是这样的
// 😂 懒得写 demo 了，将就看一下就行
-----------------------------------------------
|  |-------|                                  |
|  |       |                                  |
|  |       |                      StackKit    |
|  | Image |  ...Spacer......    Version: 1   |
|  |       |                                  |
|  |-------|                                  |
-----------------------------------------------
```

`VStackView` / `HStackView` 可以互相嵌套，尾随闭包使用 `@resultBuilder` 与 `SwiftUI` 保持一致。


## 类说明

* `HStackView` / `VStackView`
 
UIView 子类，正常用法：`view.addSubview(_:)` 即可，自动计算 size，调用 `view.sizeToFit()`，添加的子视图可使用 AutoLayout 或 frame 配置 size。


* `Divider` / `Spacer`

从 SwiftUI 吸取的灵感。可以用在 HStackView 和 VStackView 中。


#### ⚠️ 下面两个应该不常用，简单说一下：仅作为静态展示使用

* `HStackLayer` / `VStackLayer`

这两个是 CALayer 的子类，用来作静态展示时用的。


* `HStackLayerWrapperView` / `VStackLayerWrapperView`

这两个是 UIView 的之类，但是添加 UIView 进去的时候，会被转换成 CALayer 进行显示，也是用来做静态布局。

--- 

emmm... 配图啥的有空的时候我再传，现在自己测试过也在项目里用了，么得问题。




# 安装方式

现在就 SwiftPM，有 Pod 需求的可以提 PR，不然我也懒。因为这个布局都是硬算的，没有用其他第三方，作为独立的库，我觉得 SwiftPM 省事儿。

```swift
.package(url: "https://github.com/iWECon/StackKit.git", from: "1.0.0")
```
