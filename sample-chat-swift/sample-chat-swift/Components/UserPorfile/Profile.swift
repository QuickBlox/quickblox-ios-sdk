//
//  Profile.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation
import Quickblox

struct UserProfileConstant {
    static let currentProfile = "currentProfile"
}

class Profile: NSObject  {
    
    // MARK: - Public Class Methods
    class func synchronize(withUser user: QBUUser) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: UserProfileConstant.currentProfile)
            userDefaults.synchronize()
        } catch {
            debugPrint("[Profile] Couldn't write file to UserDefaults")
        }
    }
    
    class func clear() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: UserProfileConstant.currentProfile)
        userDefaults.synchronize()
    }
    
    //MARK: - Internal Class Methods
    private class func loadObject() -> QBUUser? {
        let userDefaults = UserDefaults.standard
        guard let decodedUser  = userDefaults.object(forKey: UserProfileConstant.currentProfile) as? Data else {
            debugPrint("[Profile] Couldn't read file from UserDefaults")
            return nil }
        do {
            if let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decodedUser) as? QBUUser {
                return user
            } else {
                debugPrint("[Profile] Couldn't read file from UserDefaults")
                return nil
            }
        } catch {
            debugPrint("[Profile] Couldn't read file userDefaults.object(forKeys")
            return nil
        }
    }
    
    //MARK - Properties
    var isFull: Bool {
        return user != nil
    }
    
    var ID: UInt {
        return user!.id
    }
    
    var login: String {
        return user!.login!
    }
    
    var password: String {
        return user!.password!
    }
    
    var fullName: String {
        return user!.fullName!
    }
    
    private var user: QBUUser? = {
        return Profile.loadObject()
    }()
}
