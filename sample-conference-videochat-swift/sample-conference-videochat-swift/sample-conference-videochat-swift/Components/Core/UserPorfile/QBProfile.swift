//
//  QBProfile.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import Security

struct QBProfileConstants {
    static let kQBProfile = "curentProfile"
    static let kQBUser = "qbuser"
}

let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecAttrAccessibleValue = NSString(format: kSecAttrAccessible)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
let kSecAttrAccessibleAfterFirstUnlockValue = NSString(format: kSecAttrAccessibleAfterFirstUnlock)

//class QBProfile: Codable {
class QBProfile: NSObject, NSCoding{
    
    /**
     *  User data.
     */
    var userData: QBUUser?
    
    /**
     *  Returns loaded current profile with user.
     *
     *  @return current profile
     */
    //    + (nullable instancetype)currentProfile;
    public func currentProfile() -> QBUUser{
        return QBUUser()
    }
    
    /**
     *  Synchronize current profile in keychain.
     *
     *  @return whether synchronize was successful
     */
    private func synchronize() -> OSStatus {
        assert(self.userData != nil)
        //        return [self saveData:self forKey:kQBProfile];
        return OSStatus.init(exactly: 12.0)!
    }
    
    /**
     *  Synchronize user data in keychain.
     *
     *  @param userData user data to synchronize
     *
     *  @return whether synchronize was successful
     */
    private func synchronizeWithUserData(userData: QBUUser) -> OSStatus {
        return OSStatus.init(exactly: 12.0)!
    }
    
    /**
     *  Remove all user data.
     *
     *  @return Whether clear was successful
     */
    private func clearProfile() -> OSStatus {
        return OSStatus.init(exactly: 12.0)!
    }
    
    // MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userData, forKey: QBProfileConstants.kQBUser)
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let userData = aDecoder.decodeObject(forKey: QBProfileConstants.kQBUser) {
            self.userData = userData as? QBUUser
        }
    }
    
    private func saveData(data: Any, forKey key: String) -> OSStatus {
        
        let keychainQuery = self.getKeychainQueryFor(key: key)
        SecItemDelete(keychainQuery as CFDictionary)
        keychainQuery[kSecValueDataValue] = NSKeyedArchiver.archivedData(withRootObject: data)
        return SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    // MARK: - Keychain
    private func loadObjectFor(key: String) -> Any? {
        
        var ret: AnyObject? = nil
        let keychainQuery = self.getKeychainQueryFor(key: key)
        keychainQuery[kSecReturnDataValue] = kCFBooleanTrue
        keychainQuery[kSecMatchLimitValue] = kSecMatchLimitOneValue
        var dataTypeRef :AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                ret = NSKeyedUnarchiver.unarchiveObject(with: (retrievedData)) as AnyObject
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }

        return ret
    }
    
    private func deleteObjectForKey(key: String) -> OSStatus {
        
        let keychainQuery = self.getKeychainQueryFor(key: key)
        return SecItemDelete(keychainQuery as CFDictionary)
    }
    
    private func getKeychainQueryFor(key: String) -> NSMutableDictionary {
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, key, key, kSecAttrAccessibleAfterFirstUnlockValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecAttrAccessibleValue])
        return keychainQuery
    }
}
