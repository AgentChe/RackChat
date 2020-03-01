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
    
    private var chatsList: [ChatListItem] = [ChatListItem]()
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
    
    func messageExist (id: Int) -> Bool {
        let realm = try! Realm()
        return realm.object(ofType: MessageRealm.self, forPrimaryKey: id) != nil
    }
    
    func unsendetMessageExist(cacheID: String) -> Bool {
        let realm = try! Realm()
        return realm.object(ofType: UnsendetMessageRealm.self, forPrimaryKey: cacheID) != nil
    }
    
    func getFailedMessages(id: Int) -> [Message] {
        do {
            
            let realm = try Realm()
            
            let list = realm.objects(UnsendetMessageRealm.self).filter("sendet == false AND ANY id == \(id)")
            var array: [Message] = [Message]()
            debugPrint("==============================")
            debugPrint("CaheData: FAILED MEESSAGES LIST")
            debugPrint("count: ", list.count)
              
            if list.count != 0 {
                  
                list.forEach { (item) in
//                    let matchID: Int = item.matchID
                    debugPrint("realm match ID: ", item.matchID)
                    debugPrint("realm senderID: ", item.senderID)
                    debugPrint("realm body: ", item.body)
                    debugPrint("----------------------------")
                    
                    
                    
                    var messageItem: Message = Message(unsendetMessage: item)
                    
                    if messageItem.type == .image {
                        if let retrievedImage: UIImage = try! Disk.retrieve(item.imagePath, from: .documents, as: UIImage.self) {
                            messageItem.sendetImage = retrievedImage
                        }
                                       }
//                    if id == matchID {
                        array.append(messageItem)
//                    }
                    
                    
                  }
                  debugPrint("==============================")
                  return array
              }
            return [Message]()
        } catch let error {
            debugPrint(error.localizedDescription)
            return [Message]()
        }
    }
    func getChatMessages(id: Int) -> [Message] {
        do {
            
            let realm = try Realm()
            
            let list = realm.objects(MessageRealm.self)
            var array: [Message] = [Message]()
            debugPrint("==============================")
            debugPrint("CaheData: CURRENT CHAT LIST")
            debugPrint("count: ", list.count)
              
            if list.count != 0 {
                  
                list.forEach { (item) in
                    let matchID: Int = item.matchID
                    debugPrint("realm id: ", item.id)
                    debugPrint("realm match ID: ", item.matchID)
                    debugPrint("realm senderID: ", item.senderID)
                    debugPrint("realm body: ", item.body)
                   
                    var messageItem: Message = Message(realm: item)
                    
                    if messageItem.type == .image {
                        debugPrint(":::::::::::::::::::::::::")
                        debugPrint("realm image path", item.imageFilePath)
                        debugPrint(":::::::::::::::::::::::::")
                        
                        if item.imageFilePath != "" {
                            if let retrievedImage: UIImage = try! Disk.retrieve(item.imageFilePath, from: .documents, as: UIImage.self) {
                                messageItem.sendetImage = retrievedImage
                            }
                        }
                        
                    }
                     debugPrint("----------------------------")
                    if id == matchID {
                        array.append(messageItem)
                    }
                    
                    
                  }
                  debugPrint("==============================")
                  return array
              }
            return [Message]()
        } catch let error {
            debugPrint(error.localizedDescription)
            return [Message]()
        }
    }
    
    func delete(unsendetMessage: Message) {
        do {
            let realm = try Realm()
            guard let realmUnsendetMessage: UnsendetMessageRealm = realm.object(ofType: UnsendetMessageRealm.self,
                                                                                forPrimaryKey: unsendetMessage.caheID) else {
                return
            }
            debugPrint("----------------------------")
            debugPrint("CaheData: DELETE UNSENDET MESSAGE")
            debugPrint("realm cache id: ", realmUnsendetMessage.cacheID)
            debugPrint("realm match ID: ", realmUnsendetMessage.matchID)
            debugPrint("realm senderID: ", realmUnsendetMessage.senderID)
            debugPrint("realm body: ", realmUnsendetMessage.body)
            debugPrint("----------------------------")
            
            realm.beginWrite()
            realm.delete(realmUnsendetMessage)
            try realm.commitWrite()
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func getUnsendet(id: Int) -> [Message] {
        do {
            let realm = try Realm()
            
            let list = realm.objects(UnsendetMessageRealm.self)
            var array: [Message] = [Message]()
            debugPrint("==============================")
            debugPrint("CaheData: UNSENDET MESSAGES")
            debugPrint("count: ", list.count)
              
            if list.count != 0 {
                list.forEach { (item) in
                    let matchID: Int = item.matchID
                    debugPrint("realm id: ", item.cacheID)
                    debugPrint("realm match ID: ", item.matchID)
                    debugPrint("realm senderID: ", item.senderID)
                    debugPrint("realm body: ", item.body)
                    debugPrint("----------------------------")
                    var messageItem: Message = Message(unsendetMessage: item)
                    
                    if messageItem.type == .image {
                        debugPrint(":::::::::::::::::::::::::")
                        debugPrint("realm image path", item.imagePath)
                        debugPrint(":::::::::::::::::::::::::")
                    
                        if item.imagePath != "" {
                            if let retrievedImage: UIImage = try! Disk.retrieve(item.imagePath, from: .documents, as: UIImage.self) {
                                messageItem.sendetImage = retrievedImage
                            }
                        }
                    }
                    if id == matchID {
                        array.append(messageItem)
                    }
                }
                debugPrint("==============================")
                return array
              }
            return [Message]()
        } catch let error {
            debugPrint(error.localizedDescription)
            return [Message]()
        }
    }
    
    func updateSendet(message: Message) {
        do {
            
            let realm = try Realm()
            guard let realmUnsendetMessage: UnsendetMessageRealm = realm.object(ofType: UnsendetMessageRealm.self, forPrimaryKey: message.caheID) else {
                return
            }
            
            realm.beginWrite()
            
            realm.delete(realmUnsendetMessage)
            

            
            let realmMessage: MessageRealm = MessageRealm(messageID: message.messageID,
                                                                     senderID: message.senderID,
                                                                     messageType: message.type.rawValue,
                                                                     body: message.body,
                                                                     matchID: message.matchID,
                                                                     sendet: message.sendet,
                                                                     cacheID: message.caheID)
            debugPrint("==============================")
            
            debugPrint("UPDATE MESSAGE")
            
            if message.type  == .image {
                
                if let image = message.sendetImage {
                    let path: String = "Album/\(message.caheID).png"
                    try Disk.save(image, to: .documents, as: path)
                    realmMessage.imageFilePath = path
                    debugPrint(":::::::::::::::::::::::::::::::::::::")
                    debugPrint("realm path: ", realmMessage.imageFilePath)
                    debugPrint(":::::::::::::::::::::::::::::::::::::")
                    
                }
                
                
            }
            debugPrint("realm senderID: ", realmMessage.senderID)
            debugPrint("realm cache ID: ", realmMessage.cacheID)
            debugPrint("realb sendet", realmMessage.sendet)
            debugPrint("realm body: ", realmMessage.body)
            debugPrint("==============================")
            realm.add(realmMessage, update: .modified)
            try realm.commitWrite()
            
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func add(unsendetMessage: Message) {
        do {
            
            if unsendetMessageExist(cacheID: unsendetMessage.caheID) {
                return
            }
            
            
            
            let realm = try Realm()
            
            realm.beginWrite()
            var realmMessage: UnsendetMessageRealm = UnsendetMessageRealm(cacheID: unsendetMessage.caheID,
                                                                          matchID: unsendetMessage.matchID,
                                                                          senderID: unsendetMessage.senderID,
                                                                          type: unsendetMessage.type.rawValue,
                                                                          body: unsendetMessage.body,
                                                                          sendet: unsendetMessage.sendet)
            
            debugPrint("Saving Message")
            
            if unsendetMessage.type  == .image {
                
                if let image = unsendetMessage.sendetImage  {
                    let path: String = "Album/\(unsendetMessage.caheID).png"
                    try Disk.save(image, to: .documents, as: path)
                    realmMessage.imagePath = path
                    debugPrint(":::::::::::::::::::::::::::::::::::::")
                    debugPrint("realm path: ", realmMessage.imagePath)
                    debugPrint(":::::::::::::::::::::::::::::::::::::")
                }
                
                
                
            }
           
            debugPrint("realm senderID: ", realmMessage.senderID)
            debugPrint("realm cache ID: ", realmMessage.cacheID)
            debugPrint("realb sendet", realmMessage.sendet)
            debugPrint("realm body: ", realmMessage.body)
            debugPrint("----------------------------")
//            realm.beginWrite()

            realm.add(realmMessage, update: .modified)
            try realm.commitWrite()
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func add(message: Message) {
        do {
            
            if messageExist(id: message.messageID) {
                return
            }
            
            let realm = try Realm()
            realm.beginWrite()
            
            let realmMessage: MessageRealm = MessageRealm(messageID: message.messageID,
                                                          senderID: message.senderID,
                                                          messageType: message.type.rawValue,
                                                          body: message.body,
                                                          matchID: message.matchID,
                                                          sendet: message.sendet,
                                                          cacheID: message.caheID)
            debugPrint("Saving Message")
            
            if message.type  == .image {
                
                if let image = message.sendetImage  {
                    let path: String = "Album/\(message.caheID).png"
                    try Disk.save(image, to: .documents, as: path)
                    realmMessage.imageFilePath = path
                    debugPrint(":::::::::::::::::::::::::::::::::::::")
                    debugPrint("realm path: ", realmMessage.imageFilePath)
                    debugPrint(":::::::::::::::::::::::::::::::::::::")
                    
                }
    
            }
            
            debugPrint("realm id: ", realmMessage.id)
            debugPrint("realm senderID: ", realmMessage.senderID)
            debugPrint("realm cache ID: ", realmMessage.cacheID)
            debugPrint("realb sendet", realmMessage.sendet)
            debugPrint("realm body: ", realmMessage.body)
            debugPrint("----------------------------")
            realm.add(realmMessage, update: .modified)
            try realm.commitWrite()
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func chatUpdate(chats: [ChatItem]) {
        do {
            let realm = try Realm()
            let list = realm.objects(ChatListItem.self)
            realm.beginWrite()
            var _: [ChatListItem] = self.chatsList
             if list.count > chats.count {
                
               
                var _: [ChatListItem] = []
                debugPrint("==============================")
                debugPrint("Updating: CHAT LIST")
                list.forEach { (realmItem) in
                    let deletedID = realmItem.id
                    let chat: ChatListItem = ChatListItem(id: realmItem.id, lastMessageType: realmItem.lastMessageType.value!, unreadCount: realmItem.unreadCount.value!, time: realmItem.time, partnerName: realmItem.partnerName, partnerAvatar: realmItem.partnerAvatarString, lastMessageBody: realmItem.lastMessageBody, position: 0)
                    if let _: ChatListItem = realm.object(ofType: ChatListItem.self, forPrimaryKey: deletedID) {
                        if chats.contains(where: { (chatItem) -> Bool in
                            return chat.id == chatItem.chatID
                        }) == false {
                            let predicate = NSPredicate(format: "id == \(chat.id)")
                            if let productToDelete = realm.objects(ChatListItem.self).filter(predicate).first {
                                realm.delete(productToDelete)
                            }
                        }
                        
                       
                    }
                }
                
            }
            try realm.commitWrite()
            
            if list.count == 0 {
                print("REALM: realm can't save data updating, cache data is Empty")
                return
            }
            realm.beginWrite()
          
            chats.forEach { (chatItem) in
                
                
                if let realmItem: ChatListItem = realm.object(ofType: ChatListItem.self, forPrimaryKey: chatItem.chatID) {
                    if realmItem.lastMessageBody != chatItem.lastMessageBody {
                        realmItem.lastMessageBody = chatItem.lastMessageBody
                        realmItem.lastMessageType.value = chatItem.lastMessageType.rawValue
                        realmItem.unreadCount.value = chatItem.unreadCount
                        realmItem.updatingDate = Date()
                        debugPrint("UPDATE ")
                        debugPrint("realm id: ", realmItem.id)
                        debugPrint("realm name: ", realmItem.partnerName)
                        debugPrint("realm body: ", realmItem.lastMessageBody)
                        debugPrint("----------------------------")
                        
                    }
                   
                    
                } else if chats.count > list.count {
                  let chatListItem: ChatListItem = ChatListItem(id: chatItem.chatID,
                                                                lastMessageType: chatItem.lastMessageType.rawValue,
                                                                unreadCount: chatItem.unreadCount,
                                                                time: chatItem.time,
                                                                partnerName: chatItem.partnerName,
                                                                partnerAvatar: chatItem.partnerAvatarString,
                                                                lastMessageBody: chatItem.lastMessageBody,
                                                                position: chatItem.position)
                    
                    debugPrint("ADD NEW ")
                    debugPrint("realm id: ", chatListItem.id)
                    debugPrint("realm name: ", chatListItem.partnerName)
                    debugPrint("realm body: ", chatListItem.lastMessageBody)
                 
                    debugPrint("----------------------------")
                    realm.add(chatListItem)
                
                }
                
            }
            try realm.commitWrite()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func  observeToChatList(_ observer: @escaping (_ changes: RealmCollectionChange<Results<ChatListItem>>) -> Void) {
        do {
            let realm = try Realm()
            let list = realm.objects(ChatListItem.self)
            
            notificationToken = list.observe({ (changes: RealmCollectionChange) in
                observer(changes)
            })
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    
    func getChatList() -> [ChatListItem]! {
        do {
            let realm = try Realm()
            let list = realm.objects(ChatListItem.self)
            
            var array: [ChatListItem] = [ChatListItem]()
            debugPrint("==============================")
            debugPrint("CaheData: CHATS LIST")
            debugPrint("count: ", list.count)
            
            if list.count != 0 {
                
                list.forEach { (item) in
                    debugPrint("realm id: ", item.id)
                    debugPrint("realm name: ", item.partnerName)
                    debugPrint("realm body: ", item.lastMessageBody)
                    debugPrint("----------------------------")
                    chatsList.append(item)
                    array.append(item)
                }
                debugPrint("==============================")
                array.sort { (item, nexItem) -> Bool in
                    return item.updatingDate.compare(nexItem.updatingDate) == .orderedDescending
                }
                return array
            }
            return nil
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    
    func createChatListDataSource(items: [ChatItem]) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            debugPrint("==============================")
            debugPrint("Saving: CHAT LIST")
            var realmItems: [ChatListItem] = [ChatListItem]()
            items.forEach { (chatItem) in
                let chatListItem: ChatListItem = ChatListItem(id: chatItem.chatID,
                                                              lastMessageType: chatItem.lastMessageType.rawValue,
                                                              unreadCount: chatItem.unreadCount,
                                                              time: chatItem.time,
                                                              partnerName: chatItem.partnerName,
                                                              partnerAvatar: chatItem.partnerAvatarString,
                                                              lastMessageBody: chatItem.lastMessageBody,
                                                              position: chatItem.position)
                chatListItem.updatingDate = Date()
                debugPrint("realm id: ", chatListItem.id)
                debugPrint("realm name: ", chatListItem.partnerName)
                debugPrint("realm body: ", chatListItem.lastMessageBody)
                debugPrint("----------------------------")
                realmItems.append(chatListItem)
                realm.add(chatListItem, update: .modified)
            }
            self.chatsList = realmItems
            debugPrint("==============================")
            
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
        
                debugPrint("==============================")
               
                                   
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
                
                debugPrint("CaheData: USER")
                
                debugPrint(":::::::::::::::::::::::::")
                debugPrint("avatar file path", user.avatarFileString)
                debugPrint("avatar file path", user.matchingAvatarFileURL)
                debugPrint(":::::::::::::::::::::::::")
                debugPrint("name: ", user.name)
                debugPrint("email: ", user.email)
                debugPrint("id: ", user.id)
                debugPrint("avatar URL: ", user.avatarURLString)
                debugPrint("matching avatar URL: ", user.matchingAvatarURL)
//                debugPrint("avatar file path", user.avatarFileString)
//                debugPrint("match avatar file path", user.matchingAvatarFileURL)
                debugPrint("==============================")
                
                
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

class ChatListItem: Object {
    
    @objc dynamic var id = 0
    var lastMessageType: RealmOptional<Int> = RealmOptional()
    var unreadCount: RealmOptional<Int> = RealmOptional()

    @objc dynamic var time: String = ""
    @objc dynamic var partnerName: String = ""
    @objc dynamic var partnerAvatarString: String = ""
    @objc dynamic var lastMessageBody: String = ""
    @objc dynamic var updatingDate: Date = Date()
    
    convenience init(id: Int,
                     lastMessageType: Int,
                     unreadCount: Int,
                     time: String,
                     partnerName: String,
                     partnerAvatar: String,
                     lastMessageBody: String,
                     position: Int)  {
        
        
        self.init()
        self.lastMessageType.value = lastMessageType
        self.unreadCount.value = unreadCount
        self.time = time
        self.partnerAvatarString = partnerAvatar
        self.partnerName = partnerName
        self.id = id
        self.lastMessageBody = lastMessageBody
    }
    
    override class func primaryKey() -> String? {
        return "id"
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

class UnsendetMessageRealm: Object {
    @objc dynamic var cacheID: String = ""
    @objc dynamic var matchID = 0
    var senderID: RealmOptional<Int> = RealmOptional()
    var type: RealmOptional<Int> = RealmOptional()
    @objc dynamic var body: String = ""
    @objc dynamic var sendet: Bool = false
    @objc dynamic var imagePath = ""
    
    convenience init(cacheID: String,
                     matchID: Int,
                     senderID:Int,
                     type: Int,
                     body: String,
                     sendet: Bool) {
        self.init()
        self.cacheID = cacheID
        self.matchID = matchID
        self.senderID.value = senderID
        self.type.value = type
        self.body = body
        self.sendet = sendet
    }
    
    override static func primaryKey() -> String? {
           return "cacheID"
       }
    
}

class MessageRealm: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var matchID = 0
    var senderID: RealmOptional<Int> = RealmOptional()
    var type: RealmOptional<Int> = RealmOptional()
    @objc dynamic var body: String = ""
    @objc dynamic var cacheID: String = ""
    @objc dynamic var sendet: Bool = false
    @objc dynamic var imageFilePath: String = ""
     
    convenience init(messageID: Int,
                     senderID: Int,
                     messageType: Int,
                     body: String,
                     matchID: Int,
                     sendet: Bool,
                     cacheID: String) {
        self.init()
        self.id = messageID
        self.senderID.value = senderID
        self.type.value = messageType
        self.body = body
        self.matchID = matchID
        self.sendet = sendet
        self.cacheID = cacheID
        
    }

    override static func primaryKey() -> String? {
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
