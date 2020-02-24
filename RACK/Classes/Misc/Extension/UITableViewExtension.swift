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
    var scrollToTop: Binder<Void> {
        Binder(base) { base, _ in
            base.scrollToTop()
        }
    }
    
    var reachedBottom: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else {
                    return Observable.empty()
                }

                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0, scrollView.contentSize.height - visibleHeight)
                
                return y > threshold ? .just(Void()) : Observable.empty()
            }

        return ControlEvent(events: observable)
    }
}

extension UIScrollView {
    func scrollToTop() {
        let offset = CGPoint(x: 0, y: -adjustedContentInset.top)
        if !isDragging && contentOffset != offset {
            setContentOffset(offset, animated: true)
        }
    }
}
