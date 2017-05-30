//
//  FileManager.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 28.02.17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

@property (strong, nonatomic, readonly) NSString *applicationSupportDirectory;
@property (strong, nonatomic, readonly) NSString *cachesDirectory;
@property (strong, nonatomic, readonly) NSString *documentsDirectory;
@property (strong, nonatomic, readonly) NSString *libraryDirectory;
@property (strong, nonatomic, readonly) NSString *mainBundleDirectory;
@property (strong, nonatomic, readonly) NSString *temporaryDirectory;

+ (instancetype)instance;
- (instancetype)init NS_UNAVAILABLE;

- (NSArray *)listItemsInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;
- (BOOL)removeItemAtPath:(NSString *)path;
- (NSDictionary *)attributesOfItemAtPath:(NSString *)path;
- (NSDictionary *)xattrOfItemAtPath:(NSString *)path;

@end
