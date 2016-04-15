//
//  KeychainHelper.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 12/2/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "KeychainHelper.h"

@implementation KeychainHelper

+ (OSStatus)saveKey:(NSString *)key data:(id)data {
    
	NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
	SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
	keychainQuery[(__bridge id) kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:data];
    
	return SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id)loadKey:(NSString *)key {
    
	id ret = nil;
	NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
	keychainQuery[(__bridge id) kSecReturnData] = (id) kCFBooleanTrue;
	keychainQuery[(__bridge id) kSecMatchLimit] = (__bridge id) kSecMatchLimitOne;
	CFDataRef keyData = NULL;
	
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
		@try {
			ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
		}
		@catch (NSException *e) {
			//NS Log(@"Unarchive of %@ failed: %@", service, e);
		}
		@finally {}
	}
    
	if (keyData) CFRelease(keyData);
	return ret;
}

+ (OSStatus)deleteKey:(NSString *)key {
    
	NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    
	return SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)key {
    
	return [@{(__bridge id) kSecClass : (__bridge id) kSecClassGenericPassword,
			(__bridge id) kSecAttrService : key,
			(__bridge id) kSecAttrAccount : key,
			(__bridge id) kSecAttrAccessible : (__bridge id) kSecAttrAccessibleAfterFirstUnlock} mutableCopy];
}

@end
