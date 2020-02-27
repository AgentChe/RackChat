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
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = scrollView.contentOffset.y + scrollView.contentInset.top + scrollView.contentInset.bottom
                let threshold = max(0, scrollView.contentSize.height - visibleHeight)
                return y > threshold ? .just(Void()) : Observable.empty()
            }
        
        return ControlEvent(events: observable)
    }
    
    var reachedTop: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else {
                    return Observable.empty()
                }
                
                let y = contentOffset.y + scrollView.contentInset.top + scrollView.contentInset.bottom
                return y <= 0 ? .just(Void()) : Observable.empty()
            }

        return ControlEvent(events: observable)
    }
}

extension UIScrollView {
    func scrollToTop(animated: Bool = true) {
        let offset = CGPoint(x: 0, y: -adjustedContentInset.top)
        if !isDragging && contentOffset != offset {
            setContentOffset(offset, animated: animated)
        }
    }
    
    func scrollToBottom(animated: Bool = true) {
        let offset = CGPoint(x: 0, y: -adjustedContentInset.bottom)
        if !isDragging && contentOffset != offset {
            setContentOffset(offset, animated: animated)
        }
    }
}
