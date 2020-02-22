//
//  DataManager.swift
//  FAWN
//
//  Created by Алексей Петров on 31/03/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import PromiseKit





public protocol SearchManagerProtocol: class {
    func foundet(match: Match)
    func startSearch()
    func searchWasStoppet()
    func answer(partner: CheckMatch)
    func matchWasDeny()
    func answerRequestFailed()
    func answerRequestSuccses()
}

extension SearchManagerProtocol {
    func foundet(match: Match) {}
    func startSearch() {}
    func searchWasStoppet() {}
    func answer(partner: CheckMatch) {}
    func matchWasDeny() {}
}

open class SearchManager {
    
    public enum ManagerState: Int {
        case searching
        case checking
        case foundet
        case wait
        case none
    }
    public static let startSearchNotify = Notification.Name(rawValue: "startSearch")
    public static let shared: SearchManager = SearchManager()
    
    public weak var delegate: SearchManagerProtocol!
    
    public var searshRequestTimer: Timer!
    public var checkRequestTimer: Timer!
    public var state: ManagerState = .none
  
    
//    public init() {}
    
    public func startSearch() {
        if state == .none {
//            if User.shared.isLogined() {
                self.state = .searching
                NotificationCenter.default.post(name: SearchManager.startSearchNotify, object: Void.self)
                delegate.startSearch()
                self.searshRequestTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
                    if self.state == .searching {
                         self.handleMath()
                    }
                })
//            }
        }
    }
    
    
    public func stopSearch() {
        if state == .searching {
            delegate.searchWasStoppet()
            debugPrint("Search stop")
            searshRequestTimer.invalidate()
            state = .none
        }
    }
    
    
    public func sayYes(for matchId: Double) {
        
        self.yesRequest(with: matchId).done { (response) in
            let answer: AnswerMatch = response as! AnswerMatch
            if !answer.needPayment {
                self.startCheck(matchId).done({ (response) in
                    if let check: CheckMatch = response as! CheckMatch {
                        if check.status != MatchStatus.timeOut {
                            self.delegate.answer(partner: check)
                            if self.state == .wait {
                                debugPrint("check stop")
                                self.checkRequestTimer.invalidate()
                                self.state = .none
                                
                            }
                        } else {
                            self.delegate.matchWasDeny()
                            if self.state == .wait {
                                debugPrint("check stop")
                                self.checkRequestTimer.invalidate()
                                self.state = .none
                            }
                        }
                    }
                })
            }
            }.catch { (error) in
                 debugPrint(error.localizedDescription)
        }
        
//        firstly {
//            self.yesRequest(with: matchId)
//        }.then { (response)  in
//                self.startCheck(matchId)
//        }.done { (response) in
//            if let check: CheckMatch = response as! CheckMatch {
//                if check.status != MatchStatus.timeOut {
//                    self.delegate.answer(partner: check)
//                    if self.state == .wait {
//                         debugPrint("check stop")
//                        self.checkRequestTimer.invalidate()
//                        self.state = .none
//
//                    }
//                } else {
//                    self.delegate.matchWasDeny()
//                    if self.state == .wait {
//                        debugPrint("check stop")
//                        self.checkRequestTimer.invalidate()
//                        self.state = .none
////                        self.startSearch()
//                    }
//                }
//            }
//
//        }.catch { (error) in
//            debugPrint(error.localizedDescription)
//        }
    }
    
    public func clean() {
        if searshRequestTimer != nil {
            self.searshRequestTimer.invalidate()
        }
        if checkRequestTimer != nil {
            self.checkRequestTimer.invalidate()
        }
        state = .none
    }
    
    public func sayNo(for matchId: Double) {
        firstly {
            self.noRequest(with: matchId)
            
        }.done { (response) in
                if self.state == .foundet {
                    self.state = .none
                    self.startSearch()
                }
            
        }.catch { (error) in
            debugPrint(error.localizedDescription)
        }
    }
    
    
    
    
    private func yesRequest(with matchId: Double) -> Promise<Decodable> {
        return Promise<Decodable> { seal in RequestManager.shared.request(.searchSayYes, params: ["match_id" : matchId], result: { (response) in
            if response != nil {
                let answer: AnswerMatch = response as! AnswerMatch
                if answer.needPayment {
                    self.delegate.answerRequestFailed()
                } else {
                    self.delegate.answerRequestSuccses()
                }
            }
            seal.resolve(response, nil)
        })
        }
    }
    
    private func noRequest(with matchId: Double) -> Promise<Decodable> {
        return Promise<Decodable> { seal in RequestManager.shared.request(.searchSayNo, params: ["match_id" : matchId], result: { (response) in
            if response != nil {
                let answer: AnswerMatch = response as! AnswerMatch
                if answer.needPayment {
                    self.delegate.answerRequestFailed()
                } else {
                    self.delegate.answerRequestSuccses()
                }
            }
            seal.resolve(response, nil)
        })
            
        }
    }
    
    private func check(_ matchId: Double) -> Promise<Decodable> {
        return Promise<Decodable> { seal in RequestManager.shared.request(.searchCheckMatch, params: ["match_id" : matchId], result: { (response) in
            seal.resolve(response, nil)
        })
        }
    }
    
    private func startCheck(_ matchId:Double) -> Promise<Decodable> {
        return Promise<Decodable> {
            seal in
            if state == .foundet {
                self.state = .wait
                self.checkRequestTimer = Timer.scheduledTimer(withTimeInterval: 5.0,
                                                              repeats: true,
                                                              block: { (timer) in
                                                                debugPrint("check state....")
                                                                RequestManager.shared.request(.searchCheckMatch,
                                                                                              params: ["match_id" : matchId],
                                                                                              result: { (response) in
                                                                                                let check: CheckMatch = response as! CheckMatch
                                                                                                if  check.status != MatchStatus.waitPartnerAnser {
                                                                                                    seal.resolve(response, nil)
                                                                                                }
                                                                })
                                                                
                })
            }
            
        }
    }
    
    
    private func handleMath() {
        firstly {
            search()
            }.done { [weak self] (response) in
                let match: Match = response as! Match
                if match.needPayment {
//                    NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
                    self!.stopSearch()
                }
                if match.data != nil {
                    if self!.state == .searching {
                        self!.state = .foundet
                        self!.searshRequestTimer.invalidate()
                        debugPrint("Search stop")
                        self!.delegate.foundet(match: match)
                        self!.delegate.searchWasStoppet()
                    }
                   
                }
            }.catch { (error) in
                debugPrint(error.localizedDescription)
                self.searshRequestTimer.invalidate()
        }
    }
    
    private func search() -> Promise<Decodable> {
        let email = "User.shared.userData.email"
        return Promise<Decodable> {
            seal in RequestManager.shared.request(.searchRequest, params: ["email" : email], result: { (result) in
                debugPrint("Search state.....")
                seal.resolve(result, nil)
            })
        }
            
    }
    
//    private func checkMatch() -> Promise<Any> {
//
//    }
    
    
}
