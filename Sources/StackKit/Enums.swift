//
//  File.swift
//  
//
//  Created by i on 2022/8/4.
//

import UIKit

// MARK: HStack
public enum HStackAlignment {
    case top
    case center
    case bottom
}

public enum HStackDistribution {
    /// Specify spacing
    case spacing(_ spacing: CGFloat)
    
    /// Automatic calculate spacing
    case autoSpacing
    
    /// The heights are all equal
    case fillHeight
    
    /// The widths and heights are all equal
    case fill
}

// MARK: - VStack
public enum VStackAlignment {
    case left
    case center
    case right
}


public enum VStackDistribution {
    /// Specify spacing
    case spacing(_ spacing: CGFloat)
    
    /// Automatic calculate spacing
    case autoSpacing
    
    /// The widths are all equal
    case fillWidth
    
    /// The widths and heights are all equal
    case fill
}


// MARK: - Wrap
public enum WrapStackVerticalAlignment {
    case nature
    case center
    case reverse
}

public enum WrapStackHorizontalAlignment {
    case top
    case center
    case bottom
}

public enum WrapStackItemSize {
    case fixed(_ size: CGSize)
    case adaptive(column: Int)
}

public enum WrapStackLayout {
    /// width fixed, height auto
    case width
    /// height fixed, width auto
    case height
    
    // with and height are auto
    case auto
}
