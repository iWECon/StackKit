import UIKit

// MARK: HStack
public enum HStackAlignment {
    case top
    case center
    case bottom
}

public enum HStackDistribution {
    
    /// Specify spacing. `The size of the HStack is automatically calculated.`
    case spacing(_ spacing: CGFloat)
    
    /// Automatic calculate spacing. `The width of the HStack needs to be given.`
    case autoSpacing
    
    /// The height of subviews are equal. `The height of the VStack needs to be given.`
    /// set `nil` means autoSpacing
    case fillHeight(_ spacing: CGFloat? = nil)
    
    /// The width and height of subviews are equal. `The size of the HStack needs to be given.`
    case fill
}

// MARK: - VStack
public enum VStackAlignment {
    case left
    case center
    case right
}


public enum VStackDistribution {
    
    /// Specify spacing. `The size of the VStack is automatically calculated.`
    case spacing(_ spacing: CGFloat)
    
    /// Automatic calculate spacing. `The height of the VStack needs to be given.`
    case autoSpacing
    
    /// The widths are all equal. `The width of the VStack needs to be given.`
    /// set `nil` means autoSpacing
    case fillWidth(_ spacing: CGFloat? = nil)
    
    /// The widths and heights are all equal. `The size of the V Stack needs to be given.`
    case fill
}


// MARK: - Wrap
public enum WrapStackVerticalAlignment {
    
    /// Items are arranged from left to right.
    ///
    /// ---------------------        ---------------------
    /// |                   |        |                   |
    /// | v1                |    ->  | v1 | v2 | v3      |    << arranged from left to right.
    /// |                   |        |                   |
    /// ---------------------        ---------------------
    ///
    case nature
    
    /// Items are arranged from the center.
    ///
    /// ---------------------        ---------------------
    /// |                   |        |                   |
    /// |        v1         |    ->  |    v1 | v2 | v3   |    << arranged from the center.
    /// |                   |        |                   |
    /// ---------------------        ---------------------
    ///
    case center
    
    /// TODO: ⚠️ Not Completed
    /// Items are arranged from right to left.
    ///
    /// ---------------------        ---------------------
    /// |                   |        |                   |
    /// |                v1 |    ->  |      v3 | v2 | v1 |    << arranged from right to left.
    /// |                   |        |                   |
    /// ---------------------        ---------------------
    ///
    case reverse
}

public enum WrapStackHorizontalAlignment {
    
    /// Horizontal items are aligned to the top.
    ///
    /// ---------------------------------
    /// |  |----|   |----|              |    << items are aligned to the top.
    /// |  |    |   | v2 |              |
    /// |  | v1 |   |----|              |
    /// |  |    |                       |
    /// |  |----|                       |
    /// ---------------------------------
    ///
    case top
    
    /// Horizontal items are aligned to the center.
    ///
    /// ---------------------------------
    /// |  |----|                       |
    /// |  |    |   |----|              |
    /// |  | v1 |   | v2 |              |    << items are aligned to the center.
    /// |  |    |   |----|              |
    /// |  |----|                       |
    /// ---------------------------------
    ///
    case center
    
    /// Horizontal items are aligned to the bottom.
    ///
    /// ---------------------------------
    /// |  |----|                       |
    /// |  |    |                       |
    /// |  | v1 |   |----|              |
    /// |  |    |   | v2 |              |
    /// |  |----|   |----|              |    << items are aligned to the bottom.
    /// ---------------------------------
    ///
    case bottom
}

public enum WrapStackItemSize {
    case fixed(_ size: CGSize)
    case adaptive(column: Int)
}

public enum WrapStackLayout {
    /// Fixed width, adaptive height. default is 0, 0 means to use the current width.
    case width(_ value: CGFloat = 0)
    
    /// Fixed height, adaptive width. default is 0, 0 means to use the current height.
    case height(_ value: CGFloat = 0)
    
    /// Calculate the size with a given size, and the final size may not be the same as the size.
    case fit(size: CGSize)
    
    /// Width and height adaptive.
    case auto
}
