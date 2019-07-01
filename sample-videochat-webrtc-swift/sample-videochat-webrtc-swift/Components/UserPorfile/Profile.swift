//
//  Profile.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/7/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox

struct UserProfileConstant {
    static let curentProfile = "curentProfile"
}

class Profile: NSObject  {
    
    // MARK: - Public Methods
    class func currentUser() -> User? {
        guard let current = Profile.loadObject() else {
            return nil
        }
        let user = User(user: current)
        return user
    }
    
    class func clearProfile() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserProfileConstant.curentProfile)
    }
    
    class func synchronize(_ user: QBUUser) {
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: UserProfileConstant.curentProfile)
    }
    
    class func update(_ user: QBUUser) {
        if let current = Profile.loadObject() {
            if let fullName = user.fullName {
                current.fullName = fullName
            }
            if let login = user.login {
                current.login = login
            }
            if let password = user.password {
                current.password = password
            }
            Profile.synchronize(current)
        } else {
            Profile.synchronize(user)
        }
    }
    
   //MARK: - Internal Class Methods
   private class func loadObject() -> QBUUser? {
        let userDefaults = UserDefaults.standard
        guard let decodedUser  = userDefaults.object(forKey: UserProfileConstant.curentProfile) as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as? QBUUser else {
                return nil
        }
        
        return user
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
    
    var tags: [String]? {
        return user!.tags
    }
    
    private var user: QBUUser? = {
        return Profile.loadObject()
    }()
}
