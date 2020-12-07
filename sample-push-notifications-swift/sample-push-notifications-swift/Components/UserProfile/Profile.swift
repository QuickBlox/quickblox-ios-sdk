//
//  Profile.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 3/19/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox

struct UserProfileConstant {
    static let curentProfile = "curentProfile"
}

class Profile: NSObject  {
    
    // MARK: - Public Class Methods
    class func synchronize(withUser user: QBUUser) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: UserProfileConstant.curentProfile)
        } catch {
            debugPrint("[Profile] Couldn't write file to UserDefaults")
        }
    }
    
    class func clear() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserProfileConstant.curentProfile)
    }
    
    //MARK: - Internal Class Methods
    private class func loadObject() -> QBUUser? {
        let userDefaults = UserDefaults.standard
        guard let decodedUser  = userDefaults.object(forKey: UserProfileConstant.curentProfile) as? Data else { return nil }
        do {
            if let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decodedUser) as? QBUUser {
                return user
            }
        } catch {
            debugPrint("[Profile] Couldn't read file from UserDefaults")
            return nil
        }
        return nil
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

