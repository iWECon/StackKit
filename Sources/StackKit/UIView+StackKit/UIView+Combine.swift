//
//  File.swift
//  
//
//  Created by bro on 2022/11/22.
//

import UIKit
import Combine

fileprivate func safetyAccessUI(_ closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
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
            safetyAccessUI {
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
            safetyAccessUI {
                view.isHidden = output
            }
        }
        return self
    }
    
}

/**
 这里由于设计逻辑，会有个问题
 
 系统提供的 receive(on: DispatchQueue.main) 虽然也可以
    ⚠️ 但是：DispatchQueue 是个调度器
 任务添加后需要等到下一个 loop cycle 才会执行
 这样就会导致一个问题：
    ❌ 在主线程中修改值，并触发 `container.setNeedsLayout()` 的时候，
 `setNeedsLayout` 会先执行，而 `publisher` 会将任务派发到下一个 loop cycle (也就是 setNeedsLayout 和 receive 先后执行的问题)
 所以这里采用 `safetyAccessUI` 来处理线程问题
 */

@available(iOS 13.0, *)
extension StackKitCompatible where Base: UILabel {
    
    @discardableResult
    public func receive(
        text publisher: Published<String>.Publisher,
        storeIn cancellables: inout Set<AnyCancellable>
    ) -> Self
    {
        receive(publisher: publisher, storeIn: &cancellables) { view, output in
            safetyAccessUI {
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
            safetyAccessUI {
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
            safetyAccessUI {
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
            safetyAccessUI {
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
            safetyAccessUI {
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
            safetyAccessUI {
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
            safetyAccessUI {
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
            safetyAccessUI {
                view.attributedText = output
            }
        }
    }
}
