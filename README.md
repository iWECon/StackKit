# StackKit

☝️ A layout library similar to SwiftUI.

🔥 Support `Combine` (available iOS 13.0+)

⚠️ If you have any questions or new ideas, you can bring me a PR at any time.


# Previews and codes


### Preview 1
![Demo](Demo/preview1.png)

```swift
HStackView(alignment: .center, distribution: .spacing(14), padding: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)) {
    logoView.stack.size(80)
    VStackView(alignment: .left, distribution: .spacing(6)) {
        nameLabel
        briefLabel.stack.maxWidth(220)
    }
}
```
![Demo](Demo/preview2.png)


⚠️ If you have any question, please see the demo in `Demo/Demo.xcodeproj` or submit issue.

💡 There are no more examples, you can help to complete/optimize.


### HStackView / VStackView

Alignment, Distribution, Padding and `resultBuilder`

```swift
HStackView(alignment: HStackAlignment, distribution: HStackDistribution, padding: UIEdgeInsets, content: @resultBuilder)
VStackView(alignment: VStackAlignment, distribution: VStackDistribution, padding: UIEdgeInsets, content: @resultBuilder)
```

### Subview size is fixed

```swift
logoView.stack.size(CGSize?)
```

### Min or Max width/height

```swift
briefLabel.stack.minWidth(CGFloat?)
                .maxWidth(CGFloat?)
                .minHeight(CGFloat?)
                .maxHeight(CGFloat?)
```

### Offset

```swift
briefLabel.stack.offset(CGPoint?)
                .offset(x: CGFloat?)
                .offset(y: CGFloat?)
```

### SizeToFit

```swift
briefLabel.stack.width(220).sizeToFit(.width) // see `UIView+FitSize.swift`
```

### Spacer & Divider

```swift
VStackView {
    nameLabel
    
    Spacer(length: 2) //< see `Spacer.swift`
    Divider(thickness: 2) // see `Divider.swift`
    
    briefLabel
}
```

### Then

```swift
VStackView {
    briefLabel.stack.then {
        $0.textColor = .red
    }
}
```

### Change and update

```swift
// update text
briefLabel.text = "Bump version to 1.2.2"

// stackContainer means any instance of HStackView or VStackView
stackContainer.setNeedsLayout() // or .sizeToFit() 
```

### Combine

```swift

import Combine

// ...
@Published var name: String = "StackKit"

var cancellables = Set<AnyCancellable>()

// ...
HStackView {
    UILabel()
        .stack
        .then {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .systemPink
        }
        .receive(text: $name, storeIn: &cancellables)
}

// update name
self.name = "StackKit version 1.2.3"
// update stackView
stackView.setNeedsLayout()

// remember cleanup cancellables in deinit
deinit {
    // the effective same as `cancellables.forEach { $0.cancel() }`
    cancellables.removeAll()
}
```

# 🤔 

I'm not very good at writing documents. If you have the advantages in this regard, please submit PR to me. Thank you very much.


# Installation

```swift
.package(url: "https://github.com/iWECon/StackKit.git", from: "1.0.0")
```
