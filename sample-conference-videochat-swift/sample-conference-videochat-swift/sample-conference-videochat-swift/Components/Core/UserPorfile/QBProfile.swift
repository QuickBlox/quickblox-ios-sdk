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

struct QBProfileSecConstants {
    static let kSecClassValue = NSString(format: kSecClass)
    static let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
    static let kSecValueDataValue = NSString(format: kSecValueData)
    static let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
    static let kSecAttrServiceValue = NSString(format: kSecAttrService)
    static let kSecAttrAccessibleValue = NSString(format: kSecAttrAccessible)
    static let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
    static let kSecReturnDataValue = NSString(format: kSecReturnData)
    static let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
    static let kSecAttrAccessibleAfterFirstUnlockValue = NSString(format: kSecAttrAccessibleAfterFirstUnlock)
}

//class QBProfile: Codable {
class QBProfile: NSObject, NSCoding{
    
    /**
     *  User data.
     */
    private var userData: QBUUser?
    
    /**
     *  Synchronize current profile in keychain.
     *
     *  @return whether synchronize was successful
     */
    func synchronize() -> OSStatus {
        
        assert(userData != nil, "Invalid parameter not satisfying: userData != nil")
        return self.saveData(data: self.userData as Any, forKey: QBProfileConstants.kQBProfile)
    }
    
    /**
     *  Returns loaded current profile with user.
     *
     *  @return current profile
     */
    class func currentProfile() -> QBProfile {
        return QBProfile()
    }
    
    override init() {
        super.init()
        loadProfile()
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        
        super.init()
        userData = aDecoder.decodeObject(forKey: QBProfileConstants.kQBUser) as? QBUUser
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(userData, forKey: QBProfileConstants.kQBUser)
    }

    /**
     *  Synchronize user data in keychain.
     *
     *  @param userData user data to synchronize
     *
     *  @return whether synchronize was successful
     */
    public func synchronizeWithUserData(userData: QBUUser) -> OSStatus {
        self.userData = userData;
        let status: OSStatus = synchronize()
        return status;
    }
    
    private func loadProfile() {
        let profile: QBProfile = self.loadObjectFor(key: QBProfileConstants.kQBProfile) as! QBProfile
        self.userData = profile.userData;
    }
    
    /**
     *  Remove all user data.
     *
     *  @return Whether clear was successful
     */
    public func clearProfile() -> OSStatus {
        let success: OSStatus = self.deleteObjectForKey(key: QBProfileConstants.kQBProfile)
        self.userData = nil;
        return success;
    }
    
    private func saveData(data: Any, forKey key: String) -> OSStatus {
        
        let keychainQuery = self.getKeychainQueryFor(key: key)
        SecItemDelete(keychainQuery as CFDictionary)
        keychainQuery[QBProfileSecConstants.kSecValueDataValue] = NSKeyedArchiver.archivedData(withRootObject: data)
        return SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    // MARK: - Keychain
    private func loadObjectFor(key: String) -> Any? {
        
        var ret: AnyObject? = nil
        let keychainQuery = self.getKeychainQueryFor(key: key)
        keychainQuery[QBProfileSecConstants.kSecReturnDataValue] = kCFBooleanTrue
        keychainQuery[QBProfileSecConstants.kSecMatchLimitValue] = QBProfileSecConstants.kSecMatchLimitOneValue
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
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [QBProfileSecConstants.kSecClassGenericPasswordValue, key, key, QBProfileSecConstants.kSecAttrAccessibleAfterFirstUnlockValue], forKeys: [QBProfileSecConstants.kSecClassValue, QBProfileSecConstants.kSecAttrServiceValue, QBProfileSecConstants.kSecAttrAccountValue, QBProfileSecConstants.kSecAttrAccessibleValue])
        return keychainQuery
    }
}
