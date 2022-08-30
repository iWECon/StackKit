import UIKit

public protocol StackKitCompatibleProvider {
    associatedtype O
    var stack: O { get }
    static var stack: O { get }
}
