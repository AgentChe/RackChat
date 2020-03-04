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
                
                let userShow: UserShow = UserShow(realm: user, status: .succses)
    
                if user.avatarFileString != "" {
                    if let retrievedImage: UIImage = try Disk.retrieve(user.avatarFileString, from: .documents, as: UIImage.self) {
                        userShow.avatar = retrievedImage
                    }
                }
                
                if user.matchingAvatarFileURL != "" {
                    if let retrievedImage: UIImage = try Disk.retrieve(user.matchingAvatarFileURL, from: .documents, as: UIImage.self) {
                        userShow.matchingAvatar = retrievedImage
                    }
                }
                
                return userShow
            }
            return nil
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }

    func saveUser(image: UIImage, type: UserImageTypes) {
        do {
            let realm = try Realm()
            let users = realm.objects(UserRealm.self)
            
            if users.count == 0 {
                print("REALM: realm can't get data updating, cache data is Empty")
                return
            }
            
            guard let currentUser:UserRealm = users.first else {
                print("REALM: realm can't get data updating, cache data is Empty")
                return
            }
            
            debugPrint("==============================")
            debugPrint("CaheData: USER")
            debugPrint("SAVE image type: ", type.rawValue)
            realm.beginWrite()
            switch type {
            case .matching:
                let path: String = "User/\(currentUser.id)_match.png"
                try Disk.save(image, to: .documents, as: path)
                currentUser.matchingAvatarFileURL = path
                debugPrint(":::::::::::::::::::::::::::::::::::::")
                debugPrint("realm Match Pic paht: ", currentUser.matchingAvatarFileURL)
                debugPrint(":::::::::::::::::::::::::::::::::::::")
            case .userPic:
                let path: String = "User/\(currentUser.id)_userPic.png"
                try Disk.save(image, to: .documents, as: path)
                currentUser.avatarFileString = path
                debugPrint(":::::::::::::::::::::::::::::::::::::")
                debugPrint("realm User Pic paht: ", currentUser.avatarFileString)
                debugPrint(":::::::::::::::::::::::::::::::::::::")
            }
            debugPrint("==============================")
            try realm.commitWrite()
        } catch let error {
            debugPrint(error.localizedDescription)
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
                                                      lookingFor: user.lookingFor,
                                                      userID: user.id,
                                                      notifyOnMessage: user.notifyOnMessage,
                                                      notifyOnMatch: user.notifyOnMatch,
                                                      notifyOnUsers: user.notifyOnUsers,
                                                      notifyOnKnocks: user.notifyOnKnocks,
                                                      photosCount: user.photosCount,
                                                      photos: user.photos,
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
    var lookingFor: RealmOptional<Int> = RealmOptional()
    @objc dynamic var id = 0
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var avatarURLString: String = ""
    @objc dynamic var avatarFileString: String = ""
    @objc dynamic var matchingAvatarURL: String = ""
    @objc dynamic var matchingAvatarFileURL: String = ""
    @objc dynamic var notifyOnMessage: Bool = false
    @objc dynamic var notifyOnMatch: Bool = false
    @objc dynamic var notifyOnUsers: Bool = false
    @objc dynamic var notifyOnKnocks: Bool = false
    
    @objc dynamic var photosCount: Int = 0
    @objc dynamic var age: Int = 0
    @objc dynamic var city: String = ""

    let photos = List<String>()

    convenience init(email: String,
                     name: String,
                     avatarURL: String,
                     matchingAvatarURL: String,
                     gender: Int,
                     lookingFor: Int,
                     userID:Int,
                     notifyOnMessage: Bool,
                     notifyOnMatch: Bool,
                     notifyOnUsers: Bool,
                     notifyOnKnocks: Bool,
                     photosCount: Int,
                     photos: [String],
                     age: Int,
                     city: String)
    {
        self.init()
        self.id = userID
        self.gender.value = gender
        self.lookingFor.value = lookingFor
        self.email = email
        self.name = name
        self.avatarURLString = avatarURL
        self.matchingAvatarURL = matchingAvatarURL
        self.notifyOnMatch = notifyOnMatch
        self.notifyOnUsers = notifyOnUsers
        self.notifyOnKnocks = notifyOnKnocks
        self.notifyOnMessage = notifyOnMessage
        self.photos.append(objectsIn: photos)
        self.photosCount = photosCount
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
