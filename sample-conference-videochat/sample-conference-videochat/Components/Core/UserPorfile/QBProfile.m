//
//  QBProfile.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 02/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBProfile.h"
#import <Quickblox/Quickblox.h>

NSString *const kQBProfile = @"curentProfile";
NSString *const kQBUser = @"qbuser";

@interface QBProfile()

@property (strong, nonatomic, readwrite) QBUUser *userData;

@end

@implementation QBProfile

+ (instancetype)currentProfile {
    
    return [[self alloc] init];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self loadProfile];
    }
    
    return self;
}

- (OSStatus)synchronize {
    
    NSParameterAssert(self.userData);
    return [self saveData:self forKey:kQBProfile];
}

- (OSStatus)synchronizeWithUserData:(QBUUser *)userData {
    
    self.userData = userData;
    OSStatus status = [self synchronize];
    
    return status;
}

- (void)loadProfile {
    
    QBProfile *profile = [self loadObjectForKey:kQBProfile];
    self.userData = profile.userData;
}

- (OSStatus)clearProfile {
    
    OSStatus success = [self deleteObjectForKey:kQBProfile];
    
    self.userData = nil;
    
    return success;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        
        _userData = [aDecoder decodeObjectForKey:kQBUser];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.userData forKey:kQBUser];
}

- (OSStatus)saveData:(id)data forKey:(NSString *)key {
    
    NSMutableDictionary *keychainQuery = [self getKeychainQueryForKey:key];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    keychainQuery[(__bridge id) kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:data];
    
    return SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

#pragma mark - keychain

- (id)loadObjectForKey:(NSString *)key {
    
    id ret = nil;
    
    NSMutableDictionary *keychainQuery = [self getKeychainQueryForKey:key];
    
    keychainQuery[(__bridge id) kSecReturnData] = (id) kCFBooleanTrue;
    keychainQuery[(__bridge id) kSecMatchLimit] = (__bridge id) kSecMatchLimitOne;
    CFDataRef keyData = NULL;
    
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
    }
    
    if (keyData) CFRelease(keyData);
    
    return ret;
}

- (OSStatus)deleteObjectForKey:(NSString *)key {
    
    NSMutableDictionary *keychainQuery = [self getKeychainQueryForKey:key];
    
    return SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

- (NSMutableDictionary *)getKeychainQueryForKey:(NSString *)key {
    
    return [@{(__bridge id) kSecClass : (__bridge id) kSecClassGenericPassword,
              (__bridge id) kSecAttrService : key,
              (__bridge id) kSecAttrAccount : key,
              (__bridge id) kSecAttrAccessible : (__bridge id) kSecAttrAccessibleAfterFirstUnlock} mutableCopy];
}

@end
