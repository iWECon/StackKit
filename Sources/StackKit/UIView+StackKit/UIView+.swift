import UIKit

extension UIView {
    
    public func addSubview<T>(_ compatibleWrapper: StackKitCompatible<T>) where T: UIView {
        self.addSubview(compatibleWrapper.view)
    }
    
}
