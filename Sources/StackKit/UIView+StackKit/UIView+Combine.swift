//
//  File.swift
//  
//
//  Created by bro on 2022/11/22.
//

import UIKit
import Combine

/// Safety Access UI.
///
/// A scheduler that performs all work on the main queue, as soon as possible.
///
/// If the caller is already running on the main queue when an action is
/// scheduled, it may be run synchronously. However, ordering between actions
/// will always be preserved.
fileprivate final class UIScheduler {
    private static let dispatchSpecificKey = DispatchSpecificKey<UInt8>()
    private static let dispatchSpecificValue = UInt8.max
    private static var __once: () = {
            DispatchQueue.main.setSpecific(key: UIScheduler.dispatchSpecificKey,
                                           value: dispatchSpecificValue)
    }()
    
    private let queueLength: UnsafeMutablePointer<Int32> = {
        let memory = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        memory.initialize(to: 0)
        return memory
    }()
    
    deinit {
        queueLength.deinitialize(count: 1)
        queueLength.deallocate()
    }
    
    init() {
        /// This call is to ensure the main queue has been setup appropriately
        /// for `UIScheduler`. It is only called once during the application
        /// lifetime, since Swift has a `dispatch_once` like mechanism to
        /// lazily initialize global variables and static variables.
        _ = UIScheduler.__once
    }
    
    /// Queues an action to be performed on main queue. If the action is called
    /// on the main thread and no work is queued, no scheduling takes place and
    /// the action is called instantly.
    func schedule(_ action: @escaping () -> Void) {
        let positionInQueue = enqueue()
        
        // If we're already running on the main queue, and there isn't work
        // already enqueued, we can skip scheduling and just execute directly.
        if positionInQueue == 1, DispatchQueue.getSpecific(key: UIScheduler.dispatchSpecificKey) == UIScheduler.dispatchSpecificValue {
            action()
            dequeue()
        } else {
            DispatchQueue.main.async {
                defer { self.dequeue() }
                action()
            }
        }
    }
    
    private func dequeue() {
        OSAtomicDecrement32(queueLength)
    }
    private func enqueue() -> Int32 {
        OSAtomicIncrement32(queueLength)
    }
}


@available(iOS 13.0, *)
extension StackKitCompatible where Base: UIView {

    @discardableResult
    public func receive<Value>(
        publisher: Published<Value>.Publisher,
        storeIn cancellables: inout Set<AnyCancellable>,
        sink receiveValue: @escaping ((Base, Published<Value>.Publisher.Output) -> Void)
    ) -> Self
    {
        let v = self.view
        publisher.sink { [weak v] output in
            guard let v else { return }
            receiveValue(v, output)
        }.store(in: &cancellables)
        return self
    }
    
    @discardableResult
    public func receive<Value>(
        publisher: Published<Value>.Publisher,
        cancellable: inout AnyCancellable?,
        sink receiveValue: @escaping ((Base, Published<Value>.Publisher.Output) -> Void)
    ) -> Self
    {
        let v = self.view
        cancellable = publisher.sink(receiveValue: { [weak v] output in
            guard let v else { return }
            receiveValue(v, output)
        })
        return self
    }

    @discardableResult
    public func receive(
        isHidden publisher: Published<Bool>.Publisher,
        storeIn cancellables: inout Set<AnyCancellable>
    ) -> Self
    {
        receive(publisher: publisher, storeIn: &cancellables) { view, output in
            UIScheduler().schedule {
                view.isHidden = output
            }
        }
        return self
    }
    
    @discardableResult
    public func receive(
        isHidden publisher: Published<Bool>.Publisher,
        cancellable: inout AnyCancellable?
    ) -> Self
    {
        receive(publisher: publisher, cancellable: &cancellable) { view, output in
            UIScheduler().schedule {
                view.isHidden = output
            }
        }
        return self
    }
}

@available(iOS 13.0, *)
extension StackKitCompatible where Base: UILabel {
    
    @discardableResult
    public func receive(
        text publisher: Published<String>.Publisher,
        storeIn cancellables: inout Set<AnyCancellable>
    ) -> Self
    {
        receive(publisher: publisher, storeIn: &cancellables) { view, output in
            UIScheduler().schedule {
                view.text = output
            }
        }
    }
    
    @discardableResult
    public func receive(
        text publisher: Published<String>.Publisher,
        cancellable: inout AnyCancellable?
    ) -> Self
    {
        receive(publisher: publisher, cancellable: &cancellable) { view, output in
            UIScheduler().schedule {
                view.text = output
            }
        }
    }
    
    
    @discardableResult
    public func receive(
        text publisher: Published<String?>.Publisher,
        storeIn cancellables: inout Set<AnyCancellable>
    ) -> Self
    {
        receive(publisher: publisher, storeIn: &cancellables) { view, output in
            UIScheduler().schedule {
                view.text = output
            }
        }
    }
    
    @discardableResult
    public func receive(
        text publisher: Published<String?>.Publisher,
        cancellable: inout AnyCancellable?
    ) -> Self
    {
        receive(publisher: publisher, cancellable: &cancellable) { view, output in
            UIScheduler().schedule {
                view.text = output
            }
        }
    }
    
    @discardableResult
    public func receive(
        attributedText publisher: Published<NSAttributedString>.Publisher,
        storeIn cancellables: inout Set<AnyCancellable>
    ) -> Self
    {
        receive(publisher: publisher, storeIn: &cancellables) { view, output in
            UIScheduler().schedule {
                view.attributedText = output
            }
        }
    }
    
    @discardableResult
    public func receive(
        attributedText publisher: Published<NSAttributedString>.Publisher,
        cancellable: inout AnyCancellable?
    ) -> Self
    {
        receive(publisher: publisher, cancellable: &cancellable) { view, output in
            UIScheduler().schedule {
                view.attributedText = output
            }
        }
    }
    
    @discardableResult
    public func receive(
        attributedText publisher: Published<NSAttributedString?>.Publisher,
        storeIn cancellables: inout Set<AnyCancellable>
    ) -> Self
    {
        receive(publisher: publisher, storeIn: &cancellables) { view, output in
            UIScheduler().schedule {
                view.attributedText = output
            }
        }
    }
    
    @discardableResult
    public func receive(
        attributedText publisher: Published<NSAttributedString?>.Publisher,
        cancellable: inout AnyCancellable?
    ) -> Self
    {
        receive(publisher: publisher, cancellable: &cancellable) { view, output in
            UIScheduler().schedule {
                view.attributedText = output
            }
        }
    }
}
