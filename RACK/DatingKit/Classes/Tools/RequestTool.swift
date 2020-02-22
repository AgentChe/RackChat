//
//  RequestManager.swift
//  FAWN
//
//  Created by Алексей Петров on 31/03/2019.
//  Copyright © 2019 Алексей Петров. All rights reserved.
//

import Foundation
import Alamofire

class RequestTool {
    
    private var baseURL: String
    
    private var apiKey: String
    
    private var cache: CacheTool
    
    private var token: String {
        return cache.getToken()
    }
    
    init(baseURL: String, apiKey: String, cache: CacheTool) {
        self.cache = cache
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    func loadPic(from url: String, complition:@escaping(_ data: Data?) -> Void) {
          if let  url:URL = URL(string: url) {
              Alamofire.request(url).response() { (result) in
                  if let imageData = result.data {
                      complition(imageData)
                  } else {
                      complition(nil)
                  }
              }
          }
      }
    
    func request(route: String, parameters: [String : Any],
                 useToken: Bool, parcer:@escaping(_ data: Data) -> Response?,
                 completion: @escaping (Response?) -> Void) {
        
        let params = getParameters(useToken: useToken, parameters: parameters)
        let requestURL =  baseURL + route
        
        Alamofire.request(requestURL, method: .post, parameters: params , encoding: URLEncoding.default, headers: nil) .responseJSON { (response) in
            if response.result.isSuccess {
                debugPrint("==============================")
                debugPrint("parameters: %@", params)
                debugPrint("request: %@", requestURL)
                debugPrint("REQUEST RESPONSE: ")
                debugPrint(response.result)
                debugPrint("==============================")
                completion(parcer(response.data!))
            } else {
                completion(nil)
            }
        }
        
    }
    
    func requset (_ request: APIRequest, completion: @escaping (Decodable?) -> Void) {
        let parameters = getParameters(for: request)
        let requestURL =  baseURL + request.url
        
        Alamofire.request(requestURL, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil) .responseJSON { (response) in
            if response.result.isSuccess {
                debugPrint("==============================")
                debugPrint("parameters: %@", parameters)
                debugPrint("request: %@", requestURL)
                debugPrint("REQUEST RESPONSE: ")
                debugPrint(response.result)
                debugPrint("==============================")
                completion(request.parse(data: response.data!))
            } else {
                completion(nil)
            }
        }
    }
    
    private func getParameters(useToken: Bool, parameters: [String : Any]) -> [String : Any] {
        var returnedParameters:[String: Any] = parameters
        returnedParameters["_api_key"] = apiKey
        if useToken {
             returnedParameters["_user_token"] = token
        }
        return returnedParameters
    }
    
    private func getParameters(for request: APIRequest) -> [String : Any] {
        var returnedParameters:[String: Any] = request.parameters
        returnedParameters["_api_key"] = apiKey
        if request.useToken {
            returnedParameters["_user_token"] = token
        }
        return returnedParameters
    }
    
}

enum RequestGroup: Int, CaseIterable {
    case usersCreate
    case usersGenerateCode
    case usersVerefyCode
    case usersShow
    case usersRandomize
    case usersFbAuth
    case usersLogout
    case searchRequest
    case searchCheckMatch
    case searchSayYes
    case searchSayNo
    case chatsList
    case chatsGet
    case chatsUnread
    case chatsSend
    case chatsHistory
    case chatsWasRead
    case chatsReport
    case chatsUnmatch
    case purchaseGate
    case purchaseValidate
    case purchaseHack
    
    var getRequest:  String {
        switch self {
        case .usersCreate:
            return "/users/create"
        case .usersGenerateCode:
            return "/users/generate_code"
        case .usersVerefyCode:
            return "/users/verify_code"
        case .usersShow:
            return "/users/show"
        case .usersRandomize:
            return "/users/randomize"
        case .searchRequest:
            return "/requests/search"
        case .searchCheckMatch:
            return "/requests/check_match"
        case .searchSayYes:
            return "/requests/say_yes"
        case .searchSayNo:
            return "/requests/say_no"
        case .usersFbAuth:
            return "/auth/facebook_login_token"
        case .usersLogout:
            return "/users/delete_account"
        case .chatsWasRead:
            return "/chats/mark"
        case .chatsList:
            return "/chats/list"
        case .chatsGet:
            return "/chats/get"
        case .chatsHistory:
            return "/chats/history"
        case .chatsUnread:
            return "/chats/unread"
        case .chatsSend:
            return "/chats/message"
        case .chatsReport:
            return "/chats/report"
        case .chatsUnmatch:
            return "/chats/unmatch"
        case .purchaseGate:
            return "/payments/paygate"
        case .purchaseValidate:
            return "/payments/validate_receipt"
        case .purchaseHack:
            return "/payments/hack"
        }
    }
}

public class RequestManager {
    
    public static let shared: RequestManager = RequestManager()
    
    private var caheTool: CacheTool = CacheTool()
    
    var token: String! {
        return caheTool.getToken()
    }
    var baseURL: String {
        return Bundle.main.object(forInfoDictionaryKey: "base_url") as! String
    }
    
    
    var apiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "api_key") as! String
    }
    
    
    func upload(image: UIImage, with parameters: [String: Any], completion: @escaping(Any?) -> Void) {
        let params = get(baseParameters: parameters, for: .chatsSend)
        let requestURL =  baseURL + RequestGroup.chatsSend.getRequest
        let imageData: Data = image.jpegData(compressionQuality: 0.5)!
        
         weak var weakSelf = self
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(imageData, withName: "message", fileName: "swift_file\(arc4random_uniform(100)).jpeg", mimeType: "image/jpeg")
            
            for key in params.keys{
                let name = String(key)
                
                if let val = params[name] as? String{
                    multipartFormData.append(val.data(using: .utf8)!, withName: name)
                }
                
                if let val = params[name] as? Int {
                    multipartFormData.append("\(val)".data(using: String.Encoding.utf8)!, withName: name)
                }
                
                if let val = params[name] as? Double {
                    let intVal: Int = Int(val)
                    multipartFormData.append("\(intVal)".data(using: String.Encoding.utf8)!, withName: name)
                }
            }
        }, to:requestURL)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                })
                
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        debugPrint("UPLOAD REQUEST")
                        debugPrint("==============================")
                        debugPrint("parameters: %@", params)
                        debugPrint("request: %@", requestURL)
                        debugPrint("REQUEST RESPONSE: ")
                        debugPrint(response.result)
                        debugPrint("==============================")
                        completion(weakSelf!.parse(response.data!, for: .chatsSend))
                    } else {
                        completion(nil)
                    }
                }
                
            case .failure(let encodingError):
                completion(nil)
            }
            
        }
    }
    
    func getParameters(for request: APIRequestV1) -> [String : Any] {
        var returnedParameters:[String: Any] = request.parameters
        returnedParameters["_api_key"] = apiKey
        if request.useToken {
            returnedParameters["_user_token"] = token
        }
        return returnedParameters
    }
    
    public func requset (_ request: APIRequestV1, completion: @escaping (Decodable?) -> Void) {
        let parameters = getParameters(for: request)
        let requestURL =  baseURL + request.url
        
        Alamofire.request(requestURL, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil) .responseJSON { (response) in
            if response.result.isSuccess {
                debugPrint("==============================")
                debugPrint("parameters: %@", parameters)
                debugPrint("request: %@", requestURL)
                debugPrint("REQUEST RESPONSE: ")
                debugPrint(response.result)
                debugPrint("==============================")
                completion(request.parse(data: response.data!))
            } else {
                completion(nil)
            }
        }
    }
    
    func request (_ request: RequestGroup, params: [String: Any], result: @escaping (Decodable?) -> Void) {

        let parameters = get(baseParameters: params, for: request)
        let requestURL =  baseURL + request.getRequest
        weak var weakSelf = self

        Alamofire.request(requestURL, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil) .responseJSON { (response) in
            
            if response.result.isSuccess {
//                debugPrint(response.result)
                debugPrint("==============================")
                debugPrint("parameters: %@", parameters)
                debugPrint("request: %@", requestURL)
                debugPrint("REQUEST RESPONSE: ")
                debugPrint(response.result)
                debugPrint("==============================")
                result(weakSelf!.parse(response.data!, for: request))
            } else {
                result(nil)
            }
        }
    }
   

    private func get(baseParameters: [String: Any], for request: RequestGroup) -> [String: Any] {
        var returnedParameters:[String: Any] = baseParameters
         returnedParameters["_api_key"] = apiKey
        switch request {
        case .usersVerefyCode, .usersFbAuth, .usersCreate, .usersGenerateCode, .purchaseHack:
            return returnedParameters
        default:
            returnedParameters["_user_token"] = token
            return returnedParameters

        }
    }
    
   private func parse(_ data: Data, for request: RequestGroup) -> Decodable! {
        switch request {
        case .usersCreate:
            do {
                let response: TechnicalCreate = try JSONDecoder().decode(TechnicalCreate.self, from: data)
    
                return response
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        case .usersGenerateCode, .chatsReport, .chatsUnmatch, .purchaseValidate, .purchaseHack:
            do {
                let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
                return response
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
            
        case .usersVerefyCode:
            do {
                let response: Token = try JSONDecoder().decode(Token.self, from: data)
                return response
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        case .usersShow:
            do {
                let response: UserResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                if response.needPayment {
                    NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
                }
                return response
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        case .usersRandomize:
            do {
                let response: UserRandomize = try JSONDecoder().decode(UserRandomize.self, from: data)
                return response
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        case .usersFbAuth:
            do {
                let response: Token = try JSONDecoder().decode(Token.self, from: data)
                return response
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        case .usersLogout:
            do {
                let response: Technical = try JSONDecoder().decode(Technical.self, from: data)
                return response
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
           
        case .searchRequest:
            let response: Match = try! JSONDecoder().decode(Match.self, from: data)
            if response.needPayment {
                NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
            }
            return response
        case .searchCheckMatch:
            let response: CheckMatch = try! JSONDecoder().decode(CheckMatch.self, from: data)
            if response.needPayment {
                NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
            }
            return response
        case .searchSayYes:
            let response: AnswerMatch = try! JSONDecoder().decode(AnswerMatch.self, from: data)
            if response.needPayment {
                NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
            }
            return response
        case .searchSayNo:
            let response: AnswerMatch = try! JSONDecoder().decode(AnswerMatch.self, from: data)
            if response.needPayment {
                NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
            }
            return response
        case .chatsList:
             do {
                let response:MessageList = try JSONDecoder().decode(MessageList.self, from: data)
                if response.needPayment {
                    NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
                }
                return response
             } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        case .chatsUnread, .chatsHistory, .chatsGet:
            let response: Messages = try! JSONDecoder().decode(Messages.self, from: data)
            if response.needPayment {
                NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
            }
            return response
        case .chatsSend:
            let response: SendStruct = try! JSONDecoder().decode(SendStruct.self, from: data)
            if response.needPayment {
                NotificationCenter.default.post(name: PaymentManager.needPayment, object: nil)
            }
            return response
        case .chatsWasRead:
            return data
        case .purchaseGate:
            do {
            let response: PaymentResponse = try JSONDecoder().decode(PaymentResponse.self, from: data)
            return response
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
    }
    }
    
    
}

class NetworkState {
    class func isConnected() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}