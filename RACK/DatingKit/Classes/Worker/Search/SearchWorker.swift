//
//  SearchWorker.swift
//  DatingKit
//
//  Created by Алексей Петров on 18.10.2019.
//

import Foundation

open class SearchResult: Result {
    public var status: ResultStatus
    
    init(status: ResultStatus) {
        self.status = status
    }
}

