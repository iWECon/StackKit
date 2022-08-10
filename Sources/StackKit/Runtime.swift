//
//  File.swift
//  
//
//  Created by i on 2022/8/11.
//

import UIKit

struct Runtime {
    init() { }
}

extension Runtime {
    
    static func getProperty(_ object: Any, key: UnsafeRawPointer) -> Any? {
        objc_getAssociatedObject(object, key)
    }

    static func setProperty(_ object: Any, key: UnsafeRawPointer, value: Any?, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(object, key, value, policy)
    }

    static func getCGFloatProperty(_ object: Any, key: UnsafeRawPointer) -> CGFloat? {
        guard let value = getProperty(object, key: key) as? NSNumber else {
            return nil
        }
        return CGFloat(truncating: value)
    }

    static func setCGFloatProperty(_ object: Any, key: UnsafeRawPointer, _ value: CGFloat?) {
        guard let v = value else {
            objc_setAssociatedObject(object, key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return
        }
        objc_setAssociatedObject(object, key, NSNumber(value: Double(v)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
