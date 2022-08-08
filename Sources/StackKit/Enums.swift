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
    /// 宽度固定，高度自适应
    /// 0 表示使用当前的宽度
    case width(_ value: CGFloat = 0)
    
    /// 高度固定，宽度自适应
    /// 0 表示使用当前的高度
    case height(_ value: CGFloat = 0)
    
    /// 给定 size 自适应宽高
    /// 结果与给定的 size 不一定一致
    case fit(size: CGSize)
    
    /// 宽高都自适应
    case auto
}
