//
//  RealmTool.swift
//  DatingKit
//
//  Created by Алексей Петров on 25/09/2019.
//

import Foundation
import RealmSwift
import Disk
import UIKit


enum UserImageTypes: String {
    typealias RawValue = String
    case matching
    case userPic
}

class CacheTool {
    
    static let shared: CacheTool = CacheTool()
    
    private var notificationToken: NotificationToken? = nil
    
    func removeCache() {
    
        do {
            debugPrint("==============================")
            debugPrint("CaheData: REMOVING")
            debugPrint("==============================")
            
            let realm = try Realm()
            realm.beginWrite()
            realm.deleteAll()
            try realm.commitWrite()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func getUser() -> UserShow! {
        do {
            let realm = try Realm()
            let users = realm.objects(UserRealm.self)
            if users.count != 0 {
                
                
                guard let user: UserRealm = users.first else {
                    debugPrint("error! realm is nil")
                    return nil
                }
                
                return UserShow(realm: user, status: .succses)
            }
            return nil
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    func updateUser(randInfo: UserRandomize) {
        do {
            let realm = try Realm()
            let users = realm.objects(UserRealm.self)
            
            if users.count == 0 {
                print("REALM: realm can't save data updating, cache data is Empty")
                return
            }
            
            let currentUser = users.first
            
            realm.beginWrite()
            
            currentUser?.avatarURLString = randInfo.avatarURLString
            currentUser?.name = randInfo.name
            currentUser?.matchingAvatarURL = randInfo.matchingAvatarURLString
            
            try realm.commitWrite()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    
    }
    
    func saveUser(user: UserResponse) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            let userRealm: UserRealm = UserRealm.init(email: user.email,
                                                      name: user.name,
                                                      avatarURL: user.avatarURLString,
                                                      matchingAvatarURL: user.avatarTransparentHiRes,
                                                      gender: user.gender,
                                                      userID: user.id,
                                                      age: user.age,
                                                      city: user.city)
            

            userRealm.avatarURLString = user.avatarURLString
            userRealm.matchingAvatarURL = user.avatarTransparentHiRes
            
            realm.add(userRealm, update: .modified)
            
            try realm.commitWrite()
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
    }
    
    func saveToken(token: String) {
        let realm = try! Realm()
        realm.beginWrite()
        let tokenRealm: TokenRealm = TokenRealm()
        tokenRealm.tokenValue = token
        realm.add(tokenRealm, update: .modified)
        try! realm.commitWrite()
        
    }
    
    func getToken() -> String {
        let realm = try! Realm()
        let tokens = realm.objects(TokenRealm.self)
        if tokens.count != 0 {
            return tokens.first!.tokenValue!
        } else {
            return ""
        }
    }
}

class UserRealm: Object {
    var gender: RealmOptional<Int> = RealmOptional()
    @objc dynamic var id = 0
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var avatarURLString: String = ""
    @objc dynamic var matchingAvatarURL: String = ""
    @objc dynamic var age: Int = 0
    @objc dynamic var city: String = ""

    convenience init(email: String,
                     name: String,
                     avatarURL: String,
                     matchingAvatarURL: String,
                     gender: Int,
                     userID:Int,
                     age: Int,
                     city: String)
    {
        self.init()
        self.id = userID
        self.gender.value = gender
        self.email = email
        self.name = name
        self.avatarURLString = avatarURL
        self.matchingAvatarURL = matchingAvatarURL
        self.age = age
        self.city = city
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class TokenRealm: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var tokenValue: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
