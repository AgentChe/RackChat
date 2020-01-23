//
//  Array+Neighbors.swift
//  FAWN
//
//  Created by Алексей Петров on 30/03/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation

public extension Array where Element: Hashable {
    
    public func next(item: Element) -> Element? {
        if let index = self.index(of: item), index + 1 <= self.count {
            return index + 1 == self.count ? self[0] : self[index + 1]
        }
        return nil
    }
    
    public func prev(item: Element) -> Element? {
        if let index = self.index(of: item), index >= 0 {
            return index == 0 ? self.last : self[index - 1]
        }
        return nil
    }
}

extension Array where Element: Equatable {
    
    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = index(of: object) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
    @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.index(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
}
