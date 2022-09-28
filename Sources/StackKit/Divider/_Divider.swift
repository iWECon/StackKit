import UIKit

public protocol _Divider {
    var thickness: CGFloat { get }
    var maxLength: CGFloat { get set }
    var color: UIColor { get }
    var cornerRadius: CGFloat { get }
}

extension _Divider {
    public var thickness: CGFloat { 1 }
    public var color: UIColor { .gray }
    public var cornerRadius: CGFloat { 0 }
}
