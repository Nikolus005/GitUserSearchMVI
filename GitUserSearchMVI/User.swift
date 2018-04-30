//
//  User.swift
//  GitUserSearchMVI
//
//  Created by Dogether on 26/04/18.
//  Copyright © 2018 Dogether. All rights reserved.
//
import Foundation
import ObjectMapper
import ObjectMapper_Realm
import RealmSwift

class User: Object,Mappable {
    var id = RealmOptional<Int>()
    @objc dynamic var type:String? = nil
    @objc dynamic var name:String? = nil
    
    required convenience init(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        id.value <- map["id"]
        name <- map["login"]
        type <- map["type"]
    }
}

class UserList:Object,Mappable {
    var userList = [User]()
    
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        userList <- map["items"]
    }
}
