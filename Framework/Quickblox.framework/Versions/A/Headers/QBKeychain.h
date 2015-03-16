//
//  QBKeychain.h
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

/**
 Error code specific to QBKeychain that can be returned in NSError objects.
 For codes returned by the operating system, refer to SecBase.h for your
 platform.
 */
typedef NS_ENUM(OSStatus, QBKeychainErrorCode) {
	/** 
     *Some of the arguments were invalid.
     */
	QBKeychainErrorBadArguments = -1001,
};

/** QBKeychain error domain */
extern NSString *const kQBKeychainErrorDomain;

/** Account name. */
extern NSString *const kQBKeychainAccountKey;

/**
 *Time the item was created.
 *The value will be a string.
 */
extern NSString *const kQBKeychainCreatedAtKey;

/** 
 *Item class.
 */
extern NSString *const kQBKeychainClassKey;

/** 
 *Item description.
 */
extern NSString *const kQBKeychainDescriptionKey;

/**
 *Item label.
 */
extern NSString *const kQBKeychainLabelKey;

/** 
 *Time the item was last modified.
 *The value will be a string.
 */
extern NSString *const kQBKeychainLastModifiedKey;

/** Where the item was created. */
extern NSString *const kQBKeychainWhereKey;

@interface QBKeychain : NSObject

/**
 Returns a string containing the password for a given account and service, or `nil` if the Keychain doesn't have a
 password for the given parameters.
 
 @param serviceName The service for which to return the corresponding password.
 
 @param account The account for which to return the corresponding password.
 
 @return Returns a string containing the password for a given account and service, or `nil` if the Keychain doesn't
 have a password for the given parameters.
 */
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;


/**
 Deletes a password from the Keychain.
 
 @param serviceName The service for which to delete the corresponding password.
 
 @param account The account for which to delete the corresponding password.
 
 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;


/**
 Sets a password in the Keychain.
 
 @param password The password to store in the Keychain.
 
 @param serviceName The service for which to set the corresponding password.
 
 @param account The account for which to set the corresponding password.
 
 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;


/**
 Returns an array containing the Keychain's accounts, or `nil` if the Keychain has no accounts.
 
 See the `NSString` constants declared in QBKeychain.h for a list of keys that can be used when accessing the
 dictionaries returned by this method.
 
 @return An array of dictionaries containing the Keychain's accounts, or `nil` if the Keychain doesn't have any
 accounts. The order of the objects in the array isn't defined.
 */
+ (NSArray *)allAccounts;


/**
 Returns an array containing the Keychain's accounts for a given service, or `nil` if the Keychain doesn't have any
 accounts for the given service.
 
 See the `NSString` constants declared in QBKeychain.h for a list of keys that can be used when accessing the
 dictionaries returned by this method.
 
 @param serviceName The service for which to return the corresponding accounts.
 
 @return An array of dictionaries containing the Keychain's accountsfor a given `serviceName`, or `nil` if the Keychain
 doesn't have any accounts for the given `serviceName`. The order of the objects in the array isn't defined.
 */
+ (NSArray *)accountsForService:(NSString *)serviceName;


#pragma mark - Configuration

#if __IPHONE_4_0 && TARGET_OS_IPHONE
/**
 Returns the accessibility type for all future passwords saved to the Keychain.
 
 @return Returns the accessibility type.
 
 The return value will be `NULL` or one of the "Keychain Item Accessibility
 Constants" used for determining when a keychain item should be readable.
 
 @see setAccessibilityType
 */
+ (CFTypeRef)accessibilityType;

/**
 Sets the accessibility type for all future passwords saved to the Keychain.
 
 @param accessibilityType One of the "Keychain Item Accessibility Constants"
 used for determining when a keychain item should be readable.
 
 If the value is `NULL` (the default), the Keychain default will be used.
 
 @see accessibilityType
 */
+ (void)setAccessibilityType:(CFTypeRef)accessibilityType;
#endif

@end

#if __IPHONE_7_0 || __MAC_10_9
// Keychain synchronization available at compile time
#define QBKEYCHAIN_SYNCHRONIZATION_AVAILABLE 1
#endif

#ifdef QBKEYCHAIN_SYNCHRONIZATION_AVAILABLE
typedef NS_ENUM(NSUInteger, QBKeychainQuerySynchronizationMode) {
	QBKeychainQuerySynchronizationModeAny,
	QBKeychainQuerySynchronizationModeNo,
	QBKeychainQuerySynchronizationModeYes
};
#endif

/**
 Simple interface for querying or modifying keychain items.
 */
@interface QBKeychainQuery : NSObject

/** kSecAttrAccount */
@property (nonatomic, copy) NSString *account;

/** kSecAttrService */
@property (nonatomic, copy) NSString *service;

/** kSecAttrLabel */
@property (nonatomic, copy) NSString *label;

#if __IPHONE_3_0 && TARGET_OS_IPHONE
/** kSecAttrAccessGroup (only used on iOS) */
@property (nonatomic, copy) NSString *accessGroup;
#endif

#ifdef QBKEYCHAIN_SYNCHRONIZATION_AVAILABLE
/** kSecAttrSynchronizable */
@property (nonatomic) QBKeychainQuerySynchronizationMode synchronizationMode;
#endif

/** Root storage for password information */
@property (nonatomic, copy) NSData *passwordData;

/**
 This property automatically transitions between an object and the value of
 `passwordData` using NSKeyedArchiver and NSKeyedUnarchiver.
 */
@property (nonatomic, copy) id<NSCoding> passwordObject;

/**
 Convenience accessor for setting and getting a password string. Passes through
 to `passwordData` using UTF-8 string encoding.
 */
@property (nonatomic, copy) NSString *password;


///------------------------
/// @name Saving & Deleting
///------------------------

/**
 Save the receiver's attributes as a keychain item. Existing items with the
 given account, service, and access group will first be deleted.
 
 @param error Populated should an error occur.
 
 @return `YES` if saving was successful, `NO` otherwise.
 */
- (BOOL)save:(NSError **)error;

/**
 Dete keychain items that match the given account, service, and access group.
 
 @param error Populated should an error occur.
 
 @return `YES` if saving was successful, `NO` otherwise.
 */
- (BOOL)deleteItem:(NSError **)error;


///---------------
/// @name Fetching
///---------------

/**
 Fetch all keychain items that match the given account, service, and access
 group. The values of `password` and `passwordData` are ignored when fetching.
 
 @param error Populated should an error occur.
 
 @return An array of dictionaries that represent all matching keychain items or
 `nil` should an error occur.
 The order of the items is not determined.
 */
- (NSArray *)fetchAll:(NSError **)error;

/**
 Fetch the keychain item that matches the given account, service, and access
 group. The `password` and `passwordData` properties will be populated unless
 an error occurs. The values of `password` and `passwordData` are ignored when
 fetching.
 
 @param error Populated should an error occur.
 
 @return `YES` if fetching was successful, `NO` otherwise.
 */
- (BOOL)fetch:(NSError **)error;


///-----------------------------
/// @name Synchronization Status
///-----------------------------

#ifdef QBKEYCHAIN_SYNCHRONIZATION_AVAILABLE
/**
 Returns a boolean indicating if keychain synchronization is available on the device at runtime. The #define
 QBKEYCHAIN_SYNCHRONIZATION_AVAILABLE is only for compile time. If you are checking for the presence of synchronization,
 you should use this method.
 
 @return A value indicating if keychain synchronization is available
 */
+ (BOOL)isSynchronizationAvailable;
#endif
@end

