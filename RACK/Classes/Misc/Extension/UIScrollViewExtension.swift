//
//  UITableViewExtension.swift
//  SleepWell
//
//  Created by Alexander Mironov on 29/01/2020.
//  Copyright © 2020 Andrey Chernyshev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    var reachedBottom: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else {
                    return Observable.empty()
                }
                
                return scrollView.isScrolledAtBottom ? .just(Void()) : Observable.empty()
            }
        
        return ControlEvent(events: observable)
    }
    
    var reachedTop: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else {
                    return Observable.empty()
                }
                
                return scrollView.isScrolledAtTop ? .just(Void()) : Observable.empty()
            }

        return ControlEvent(events: observable)
    }
}

extension UIScrollView {
    var isScrolledAtBottom: Bool {
        let visibleHeight = bounds.height - contentInset.top - contentInset.bottom
        let y = contentOffset.y + contentInset.top + contentInset.bottom
        let threshold = max(0, contentSize.height - visibleHeight)
        return y == threshold
    }
    
    var isScrolledAtTop: Bool {
        return (contentOffset.y + contentInset.top + contentInset.bottom) <= 0
    }
    
    func scrollToTop(animated: Bool = true) {
        let offset = CGPoint(x: 0, y: -adjustedContentInset.top)
        if !isDragging && contentOffset != offset {
            setContentOffset(offset, animated: animated)
        }
    }
}
