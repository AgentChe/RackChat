//
//  UIPageViewController+Scroling.swift
//  FAWN
//
//  Created by Алексей Петров on 26/05/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import UIKit

public extension UIPageViewController {
    
    public func goToNextPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: animated, completion: nil)
    }
    
    public func goToPreviousPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: animated, completion: nil)
    }
    
}
