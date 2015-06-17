//
//  UsersDataSource.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


import Foundation


let kDefaultPassword = "x6Bt0VDy5"
let kUsersKey = "users"
let kUserIDKey = "ID"
let kFullNameKey = "fullName"
let kLoginKey = "login"
let kPasswordKey = "password"

class UsersDataSource {
    private var testUsers: [QBUUser] = []
    var colors: [UIColor] = []

    required init() {
        self.loadUsers()
        self.colors = [
            UIColor(red: 0.992, green:0.510, blue:0.035, alpha:1.000),
            UIColor(red: 0.039, green:0.376, blue:1.000, alpha:1.000),
            UIColor(red: 0.984, green:0.000, blue:0.498, alpha:1.000),
            UIColor(red: 0.204, green:0.644, blue:0.251, alpha:1.000),
            UIColor(red: 0.580, green:0.012, blue:0.580, alpha:1.000),
            UIColor(red: 0.396, green:0.580, blue:0.773, alpha:1.000),
            UIColor(red: 0.765, green:0.000, blue:0.086, alpha:1.000),
            UIColor.redColor(),
            UIColor(red: 0.786, green:0.706, blue:0.000, alpha:1.000),
            UIColor(red: 0.740, green:0.624, blue:0.797, alpha:1.000)
        ]
    }

    var users: [QBUUser] {
        get {
            return testUsers
        }
    }

    func colorAtUser(user: QBUUser) -> UIColor {
        if let idx = find(self.testUsers, user) {
            return self.colors[idx]
        } else {
            return UIColor.blackColor()
        }
    }
    
    func userByID(userID : UInt) -> QBUUser? {
        
        var user = self.users.filter({$0.ID == userID})
        
        return user.first
    }

    private func loadUsers() {
        let plistPath = NSBundle.mainBundle().pathForResource(Constants.QB_VERSION_STR + "Users", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: plistPath!)

        var swiftDict: Dictionary<String, AnyObject!> = Dictionary<String, AnyObject!>()

        for key: AnyObject in dictionary!.allKeys {
            let stringKey = key as! String
            if let keyValue: AnyObject = dictionary!.valueForKey(stringKey) {
                swiftDict[stringKey] = keyValue
            }
        }
        
        var users = swiftDict[kUsersKey] as! [Dictionary<String, AnyObject>]
        
        for user in users {
            var testUser = self.userWithID(UInt((user[kUserIDKey] as! String).toInt()!),
                    login: user[kLoginKey] as! String,
                    fullName: user[kFullNameKey] as! String,
                    password: user[kPasswordKey] as? String)

            self.testUsers.append(testUser)
        }
    }

    private func userWithID(userID: UInt, login: String, fullName: String, password: String?) -> QBUUser {
        var user = QBUUser()
        user.ID = userID
        user.login = login
        user.fullName = fullName
        user.password = password ?? kDefaultPassword
        return user
    }

}