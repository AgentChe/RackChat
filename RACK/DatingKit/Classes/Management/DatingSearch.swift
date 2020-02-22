//
//  DatingSearch.swift
//  DatingKit
//
//  Created by Алексей Петров on 19.10.2019.
//

import Foundation


open class Search {
    
    private var manager: Manager
    
    init(manager: Manager) {
        self.manager = manager
    }
        
    public func startSearch(email: String, completion: @escaping(_ match: DKMatch, _ operationStatus: ResultStatus) -> Void) {
        let task: SearchTask = SearchTask(email: email)
        manager.takeToWork(task: task) { (result) in
            let searchResult: SearchResult = result as! SearchResult
            completion(searchResult.match, searchResult.status)
        }
    }
    
    public func stopAll() {
        let task: StopAllTask = StopAllTask()
        manager.takeToWork(task: task) { (result) in
            
        }
        
    }
    
    public func stopSearch() {
        let task: StopSearchTask = StopSearchTask()
        manager.takeToWork(task: task) { (result) in
            
        }
    }
    
    public func sayNo(matchID: Int, completion: @escaping(_ operationStatus: ResultStatus) -> Void) {
        let task: SayNoTask = SayNoTask(matchID: matchID)
        manager.takeToWork(task: task) { (result) in
            completion(result.status)
        }
    }
    
    public func sayYes(matchID: Int, completion: @escaping(_ matchStatus: MatchStatus, _ operationStatus: ResultStatus) -> Void) {
        let task: SayYesTask = SayYesTask(matchID: matchID)
        manager.takeToWork(task: task) { (result) in
            let sayYesResult: AnswerResult = result as! AnswerResult
            completion(sayYesResult.matchStatus, sayYesResult.status)
        }
    }
}
