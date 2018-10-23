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

class QBProfile: NSObject, NSCoding, NSSecureCoding  {
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    var userData: QBUUser?
    
    init(userData: QBUUser?) {
        super.init()
        self.userData = userData
    }
    
    override init() {
        super.init()
        loadProfile()
    }
    
    /**
     *  Synchronize current profile in keychain.
     *
     *  @return whether synchronize was successful
     */
    func synchronize() -> OSStatus {
        
        assert(self.userData != nil, "Invalid parameter not satisfying: userData != nil")
        debugPrint("self.userData \(String(describing: self.userData))")
        return self.saveData(self.userData as Any, forKey: QBProfileConstants.kQBProfile)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
       let userData = aDecoder.decodeObject(forKey: QBProfileConstants.kQBProfile) as? QBUUser
        self.init(userData: userData)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(userData, forKey: QBProfileConstants.kQBProfile)
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
        if let profile = self.loadObject(forKey: QBProfileConstants.kQBProfile) {
            self.userData = profile;
            debugPrint("self.userData \(String(describing: self.userData))")
        } else {
            return
        }
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
    
    func saveData(_ data: Any?, forKey key: String?) -> OSStatus {
        
        var keychainQuery = getKeychainQueryFor(key: key!)
        SecItemDelete((keychainQuery as CFDictionary?)!)
        if let dataUser = data {
            keychainQuery?[QBProfileSecConstants.kSecValueDataValue] = NSKeyedArchiver.archivedData(withRootObject: dataUser)
        }
        return SecItemAdd(keychainQuery! as CFDictionary, nil)
    }
    
    // MARK: - Keychain
    func loadObject(forKey key: String?) -> QBUUser? {
        
        var ret: QBUUser? = nil
        
        var keychainQuery = getKeychainQueryFor(key: key!)
        if let aTrue = kCFBooleanTrue {
            keychainQuery?[QBProfileSecConstants.kSecReturnDataValue] = aTrue
        }
        keychainQuery?[QBProfileSecConstants.kSecMatchLimitValue] = QBProfileSecConstants.kSecMatchLimitOneValue
        var keyData: AnyObject?
        let status = SecItemCopyMatching(keychainQuery! as CFDictionary, &keyData)
        if status == noErr {
            if let aData = keyData as! Data? {
                ret = NSKeyedUnarchiver.unarchiveObject(with: aData) as? QBUUser
              return ret
            }
        }
        return ret
    }
    
    private func deleteObjectForKey(key: String) -> OSStatus {
        
        let keychainQuery = self.getKeychainQueryFor(key: key)
        return SecItemDelete(keychainQuery! as CFDictionary)
    }
    
    private func getKeychainQueryFor(key: String) -> [AnyHashable : Any]? {
        
            return ([QBProfileSecConstants.kSecClassValue: QBProfileSecConstants.kSecClassGenericPasswordValue, QBProfileSecConstants.kSecAttrServiceValue: key, QBProfileSecConstants.kSecAttrAccountValue: key, QBProfileSecConstants.kSecAttrAccessibleValue: QBProfileSecConstants.kSecAttrAccessibleAfterFirstUnlockValue])
    }
}
