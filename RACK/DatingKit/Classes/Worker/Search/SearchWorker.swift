//
//  SearchWorker.swift
//  DatingKit
//
//  Created by Алексей Петров on 18.10.2019.
//

import Foundation

enum ChekingStatus: String {
    case none
    case waitingUserAnswer
    case waitingPartnerAnswer
}



public struct Gradient {
    public var gradientStartColor: String
    public var gradientEndColor: String
    
    public init(start: String, end: String) {
        gradientStartColor = start
        gradientEndColor = end
    }
}

open class DKMatch {
    
    public var matchID: Int
    public var action: Actions
    public var matchedUserId: Int
    public var matchedUserName: String
    public var matchedAvatarString: String
    public var matchedUserGender: Gender
    public var matchedUserAvatarTransparent: String
    public var gradient: Gradient

    public var matchedUserPhotosCount: Int
    public var matchedUserPhotos: [String]
    public var matchedUserAge: Int
    public var matchedUserCity: String

    public init() {
        matchedUserId = 0
        matchID = 0
        action = .WaitUser
        matchedUserName = ""
        matchedAvatarString = ""
        matchedUserGender = .none
        matchedUserAvatarTransparent = ""
        gradient = Gradient(start: "", end: "")
        matchedUserPhotosCount = 0
        matchedUserPhotos = [String]()
        matchedUserAge = 0
        matchedUserCity = ""
    }
    
    init(matchData: MatchetData) {
        matchID  = matchData.match
        action = Actions(rawValue:  matchData.action)!
        matchedUserId = Int(matchData.matchedUserId)
        matchedUserName = matchData.matchedUserName
        matchedAvatarString = matchData.matchedAvatarString
        matchedUserAvatarTransparent = matchData.matchedUserAvatarTransparentHiRes
        gradient = Gradient(start: matchData.gradientStartColor, end: matchData.gradientEndColor)
        matchedUserGender = Gender(rawValue: matchData.matchedUserGender)!
        matchedUserPhotosCount = matchData.matchedUserPhotosCount
        matchedUserPhotos = matchData.matchedUserPhotos
        matchedUserAge = matchData.matchedUserAge
        matchedUserCity = matchData.matchedUserCity
    }
}


open class AnswerResult: Result {
    
    public var matchStatus: MatchStatus
    public var status: ResultStatus
    
    
    init(status:MatchStatus, operationStatus: ResultStatus) {
        matchStatus = status
        self.status = operationStatus
    }
    
}

open class SearchResult: Result {
    
    public var match: DKMatch
    public var status: ResultStatus
    
    init(match: DKMatch, status: ResultStatus) {
        self.match = match
        self.status = status
    }
}

class SerachWorker: Worker {
    
    private var requestTool: RequestTool
    private var errorTool: ErrorTool
    private var manager: Manager
    private var searchTimer: Timer?
    private var checkTimer: Timer?
    private var stopSearchTimer: Timer?
    private var searchTask: TrakerTask?
    private var currentMatch: DKMatch = DKMatch()
    private var checkStatus: ChekingStatus = .none
    
    init(manager: Manager, errorTool: ErrorTool, requestTool: RequestTool) {
        self.manager = manager
        self.requestTool = requestTool
        self.errorTool = errorTool
    }
    
    func canProcess() -> Bool {
        return true
    }
    
    var currentTaskStatus: TaskStatus {
        return .treatment
    }
    
    func perfom(task: TrakerTask) {
        let searchType: SearchTaskTypes = SearchTaskTypes(rawValue: task.userTask.type)!
        var trakerTask: TrakerTask = task
        trakerTask.status = .treatment
        manager.traker.updateStatusFor(traker: trakerTask)
        
        switch searchType {
        case .search:
            startSearch(task: task)
            break
        case .sayYes:
            sayYes(task: task)
            break
        case .sayNo:
            sayNo(task: task)
            break
        case .stopSearch:
            searchStop(task: task)
            break
        case .stopAll:
            stopAll(task: task)
            break
        }
        
    }
    
    private func stopAll(task: TrakerTask) {
        
        if searchTimer != nil {
            searchTimer?.invalidate()
        }
        
        if checkTimer != nil {
            checkTimer?.invalidate()
        }
        
        if self.stopSearchTimer != nil {
            self.stopSearchTimer!.invalidate()
        }
        close(task: task, with: SystemResult(status: .succses), task: .done)
    }
    
    private func searchStop(task: TrakerTask) {
        
        
        
        if (searchTimer != nil) {
            if self.stopSearchTimer != nil {
                self.stopSearchTimer!.invalidate()
            }
            searchTimer?.invalidate()
            close(task: task, with: SystemResult(status: .succses), task: .done)
            debugPrint("==========================")
            debugPrint("search was endet by user")
            debugPrint("==========================")
        } else {
            errorTool.postError(message: "search timer is always stopped", process: "search")
        }
    }
    
    
    private func sayNo(task: TrakerTask) {
        
        
        
        if NetworkState.isConnected() == false {
            self.errorTool.postError(task: task,
                                     result: SystemResult(status: .noInternetConnection),
                                     messsage: "No Internet Connection",
                                     status: .failed)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parametrs,
                            useToken: true,
                            parcer: { (data) -> Response? in
                                do {
                                    let response: AnswerMatch = try JSONDecoder().decode(AnswerMatch.self, from: data)
                                    return response
                                } catch let error {
                                    self.errorTool.postError(task: task,
                                                             result: SystemResult(status: .undifferentError),
                                                             messsage: error.localizedDescription,
                                                             status: .failed)
                                    return nil
                                }
                                
        }) { (data) in
            if data == nil {
                self.errorTool.postError(task: task, result: SystemResult(status: .undifferentError), messsage: "responce is nil", status: .failed)
                return
            }
            
            if data!.needPayment {
                self.close(task: task, with: SystemResult(status: .needPayment), task: .failed)
                return
            }
            
            if data?.httpCode == 200 {
                self.currentMatch = DKMatch()
                self.close(task: task, with: SystemResult(status: .succses), task: .done)
                self.currentMatch = DKMatch()
            } else if data?.httpCode == 400 {
                self.errorTool.postError(task: task, result: SystemResult(status: .forbitten), messsage: "forbitten", status: .failed)
            } else if data?.httpCode == 500 {
                self.errorTool.postError(task: task, result: SystemResult(status: .badGateway), messsage: "bad gateway", status: .failed)
            } else {
                
            }
        }
        
    }
    
    private func checkRequest(task: TrakerTask) {
        
        checkTimer = Timer.scheduledTimer(withTimeInterval: Settings.matchChekTime, repeats: true, block: { (timer) in
            if NetworkState.isConnected() == false {
                timer.invalidate()
                self.errorTool.postError(task: task,
                                         result: AnswerResult(status: .waitPartnerAnser, operationStatus: .noInternetConnection),
                                         messsage: "No Internet Connection",
                                         status: .failedFromInternetConnection)
                return
            }
            
            self.requestTool.request(route: "/requests/check_match",
                                     parameters: ["match_id" : self.currentMatch.matchID],
                                     useToken: true,
                                     parcer: { (data) -> Response? in
                                        do {
                                            let response: CheckMatch = try JSONDecoder().decode(CheckMatch.self, from: data)
                                            return response
                                        } catch let error {
                                            self.checkTimer?.invalidate()
                                            self.errorTool.postError(task: task,
                                                                     result: AnswerResult(status: .waitPartnerAnser, operationStatus: .undifferentError),
                                                                     messsage: error.localizedDescription,
                                                                     status: .failed)
                                            return nil
                                        }
                                        
            }) { (responce) in
                if responce == nil {
                    self.checkTimer?.invalidate()
                    self.close(task: task,
                               with: AnswerResult(status: .waitPartnerAnser, operationStatus: .undifferentError),
                               task: .failed)
                    return
                }
                
                if responce!.needPayment {
                    self.checkTimer?.invalidate()
                    self.close(task: task,
                               with: AnswerResult(status: .waitPartnerAnser, operationStatus: .needPayment),
                               task: .failed)
                    return
                }
                
                if responce?.httpCode == 500 {
                    self.checkTimer?.invalidate()
                    self.close(task: task,
                               with: AnswerResult(status: .waitPartnerAnser, operationStatus: .badGateway),
                               task: .failed)
                    return
                }
                
                if responce?.httpCode == 400 {
                    self.checkTimer?.invalidate()
                    self.close(task: task,
                               with: AnswerResult(status: .waitPartnerAnser, operationStatus: .forbitten),
                               task: .failed)
                    return
                }
                
                if responce?.httpCode == 200 {
                    let match: CheckMatch = responce as! CheckMatch
                    let status: MatchStatus = match.status
                    
                    debugPrint("==========================")
                    debugPrint("Answer from partner \(self.currentMatch.matchedUserName)")
                    
                    
                    switch status {
                    case .waitPartnerAnser:
                        break
                    case .timeOut:
                        self.checkTimer?.invalidate()
                        self.checkStatus = .none
                        self.close(task: task, with: AnswerResult(status: match.status, operationStatus: .succses), task: .done)
                    case .deny:
                        self.checkTimer?.invalidate()
                        self.checkStatus = .none
                        self.close(task: task, with: AnswerResult(status: match.status, operationStatus: .succses), task: .done)
                    case .confirmPending:
                        self.checkStatus = .none
                        self.checkTimer?.invalidate()
                        self.close(task: task, with: AnswerResult(status: match.status, operationStatus: .succses), task: .done)
                    case .lostChat:
                        self.checkStatus = .none
                        self.checkTimer?.invalidate()
                        debugPrint("system Status: \(self.checkStatus.rawValue)")
                        debugPrint("match Status: \(status)")
                        debugPrint("matchID: ", self.currentMatch.matchID)
                        self.close(task: task, with: AnswerResult(status: match.status, operationStatus: .succses), task: .done)
                    case .report:
                        self.checkStatus = .none
                        self.checkTimer?.invalidate()
                        debugPrint("system Status: \(self.checkStatus.rawValue)")
                        debugPrint("match Status: \(status)")
                        debugPrint("matchID: ", self.currentMatch.matchID)
                        self.close(task: task, with: AnswerResult(status: match.status, operationStatus: .succses), task: .done)
                    case .cantAnswer:
                        break
                    }
                    
                    debugPrint("==========================")
                    
                } else {
                    self.close(task: task,
                               with: AnswerResult(status: .cantAnswer, operationStatus: .undifferentError),
                               task: .failed)
                }
                
            }
            
        })
    }
    
    private func yesRequest(task: TrakerTask) {
        
        if NetworkState.isConnected() == false {
            self.errorTool.postError(task: task,
                                     result: AnswerResult(status: .cantAnswer, operationStatus: .noInternetConnection),
                                     messsage: "No Internet Connection",
                                     status: .failed)
            return
        }
        
        requestTool.request(route: task.userTask.route,
                            parameters: task.userTask.parametrs,
                            useToken: true,
                            parcer: { (data) -> Response? in
                                do {
                                    let response: AnswerMatch = try JSONDecoder().decode(AnswerMatch.self, from: data)
                                    return response
                                } catch let error {
                                    self.errorTool.postError(task: task,
                                                             result: AnswerResult(status: .cantAnswer, operationStatus: .undifferentError),
                                                             messsage: "wrong responce",
                                                             status: .failed)
                                    return nil
                                }
                                
        }) { (data) in
            if data == nil {
                self.close(task: task,
                           with: AnswerResult(status: .cantAnswer, operationStatus: .undifferentError),
                           task: .failed)
                return
            }
            
            if data!.needPayment {
                self.close(task: task,
                           with: AnswerResult(status: .cantAnswer, operationStatus: .needPayment),
                           task: .failed)
                return
            }
            
            if data?.httpCode == 500 {
                self.close(task: task,
                           with: AnswerResult(status: .cantAnswer, operationStatus: .badGateway),
                           task: .failed)
                return
            }
            
            if data?.httpCode == 400 {
                self.close(task: task,
                           with: AnswerResult(status: .cantAnswer, operationStatus: .forbitten),
                           task: .failed)
                return
            }
            
            if data?.httpCode == 200 {
                self.checkStatus = .waitingPartnerAnswer
                debugPrint("==========================")
                debugPrint("Answer succses")
                debugPrint("system Status: \(self.checkStatus.rawValue)")
                debugPrint("user: ", self.currentMatch.matchedUserName)
                debugPrint("matchID: ", self.currentMatch.matchID)
                debugPrint("==========================")
                task.handler(AnswerResult(status: .waitPartnerAnser, operationStatus: .succses))
                self.checkRequest(task: task)
            } else {
                self.close(task: task,
                           with: AnswerResult(status: .cantAnswer, operationStatus: .undifferentError),
                           task: .failed)
                
            }
            
        }
        
    }
    
    private func sayYes(task: TrakerTask) {
        
        if checkStatus == .waitingUserAnswer {
            yesRequest(task: task)
        } else if checkStatus == .waitingPartnerAnswer {
            checkRequest(task: task)
        }
    }
    
    private func startSearch(task: TrakerTask) {
        
        searchTask = task
        
        stopSearchTimer = Timer.scheduledTimer(withTimeInterval: Settings.searchStopTime,
                                               repeats: false) { (timer) in
                                                self.close(task: task, with: SearchResult(match: DKMatch(), status: .timeOut), task: .done)
                                                debugPrint("==========================")
                                                debugPrint("search was endet by time")
                                                debugPrint("==========================")
                                                timer.invalidate()
                                                self.searchTimer?.invalidate()
        }
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: Settings.searchTime, repeats: true, block: { (timer) in
            
            if NetworkState.isConnected() == false {
                timer.invalidate()
                self.stopSearchTimer!.invalidate()
                self.errorTool.postError(task: task,
                                         result: SearchResult(match: DKMatch(), status: .noInternetConnection),
                                         messsage: "No Internet Connection",
                                         status: .failedFromInternetConnection)
                return
            }
            
            self.requestTool.request(route: task.userTask.route,
                                     parameters: task.userTask.parametrs,
                                     useToken: true,
                                     parcer:
            { (data) -> Response? in
                do {
                    if task.userTask is SearchCityTask {
                        let response: CitiesResponse = try JSONDecoder().decode(CitiesResponse.self, from: data)
                        return response
                    } else {
                        let response: Match = try JSONDecoder().decode(Match.self, from: data)
                        return response
                    }
                } catch let error {
                    if task.userTask is SearchCityTask {
                        // ??
                        self.errorTool.postError(message: error.localizedDescription, process: "")
                    } else {
                        self.errorTool.postError(task: task,
                                                 result: SearchResult(match: DKMatch(), status: .undifferentError),
                                                 messsage: error.localizedDescription,
                                                 status: .failed)
                    }
                    return nil
                }

            }) { [weak self] (data) in

                debugPrint("==========================")
                debugPrint("search state")
                debugPrint("==========================")

                if data == nil {
                    self!.stopSearchTimer!.invalidate()
                    timer.invalidate()
                    
                    if task.userTask is SearchCityTask {
                        
                    } else {
                        self?.errorTool.postError(task: task,
                                                  result: SearchResult(match: DKMatch(), status: .undifferentError),
                                                  messsage: "Responce is nil",
                                                  status: .failed)
                    }
                    
                    return
                }
                
                if data!.needPayment {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    
                    if task.userTask is SearchCityTask {
                        
                    } else {
                        self?.close(task: task,
                                    with: SearchResult(match: DKMatch(), status: .needPayment),
                                    task: .failed)
                    }
                    return
                }
                
                if data?.httpCode == 400 {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    
                    if task.userTask is SearchCityTask {
                    } else {
                        self?.errorTool.postError(task: task,
                                                  result: SearchResult(match: DKMatch(), status: .forbitten),
                                                  messsage: data!.message,
                                                  status: .failed)
                    }
                    return
                }
                
                if data?.httpCode == 500 {
                    timer.invalidate()
                    self!.stopSearchTimer!.invalidate()
                    
                    if task.userTask is SearchCityTask {
                    } else {
                        self?.errorTool.postError(task: task,
                                                  result: SearchResult(match: DKMatch(), status: .badGateway),
                                                  messsage: data!.message,
                                                  status: .failedFromInternetConnection)
                    }
                    return
                }
                
                if data?.httpCode == 200 {
                    
                    if task.userTask is SearchCityTask {
                        
                        let result: CitiesResponse = data as! CitiesResponse
                        if let _ = result.data {
                            
                            timer.invalidate()
                            self!.stopSearchTimer!.invalidate()
                            self?.checkStatus = .none
                            
                            debugPrint("==========================")
                            debugPrint("search stopped")
                            debugPrint("Found")
                            debugPrint("system Status: \(self?.checkStatus.rawValue ?? "error")")
                            debugPrint("==========================")
                            
                            self?.close(task: task,
                                        with: CitiesResult(response: result, status: .succses),
                                        task: .done)
                            return
                            
                        }
                        else {
                            debugPrint("==========================")
                            debugPrint("no cities have been found!!")
                            debugPrint("==========================")
                        }
                    } else {
                        
                        let result: Match = data as! Match
                        if result.data != nil {
                            
                            timer.invalidate()
                            self!.stopSearchTimer!.invalidate()
                            
                            let match: DKMatch = DKMatch(matchData: result.data!)
                            self?.checkStatus = .waitingUserAnswer
                            self?.currentMatch = match
                            
                            debugPrint("==========================")
                            debugPrint("search stopped")
                            debugPrint("Found")
                            debugPrint("user: ", match.matchedUserName)
                            debugPrint("system Status: \(self?.checkStatus.rawValue ?? "error")")
                            debugPrint("matchID: ", match.matchID)
                            debugPrint("==========================")
                            
                            self?.close(task: task,
                                        with: SearchResult(match: match, status: .succses),
                                        task: .done)
                            return
                        } else {
                            debugPrint("==========================")
                            debugPrint("no persons foundet!!")
                            debugPrint("==========================")
                        }
                    }
                    
                } else {
                    self?.errorTool.postError(task: task,
                                              result: SearchResult(match: DKMatch(), status: .undifferentError),
                                              messsage: data!.message,
                                              status: .failed)
                }
            }
            
        })
        
    }
    
    private func close(task: TrakerTask, with result: Result, task status: TaskStatus) {
        var currentTask: TrakerTask = task
        currentTask.status = status
        manager.traker.close(trakerTask: currentTask)
        currentTask.handler(result)
    }
    
    
    
}

