//
//  FileManager.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 28.02.17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

#import "FileManager.h"
#import <sys/xattr.h>

@interface FileManager()

@property (strong, nonatomic, readonly) NSArray *dirs;
@property (strong, nonatomic) NSFileManager *fManager;

@end

@implementation FileManager

+ (instancetype)instance {
    
    static dispatch_once_t onceToken;
    static FileManager *_defaultManager = nil;
    dispatch_once(&onceToken, ^{
        
        _defaultManager = [FileManager alloc];
        [_defaultManager configure];
    });
    
    return _defaultManager;
}

- (void)configure {
    
    self.fManager = [NSFileManager defaultManager];
    
    _applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).lastObject;
    _cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    _documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    _libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    _mainBundleDirectory = [NSBundle mainBundle].resourcePath;
    _temporaryDirectory =  NSTemporaryDirectory();
    
    _dirs = @[
              _applicationSupportDirectory,
              _cachesDirectory,
              _documentsDirectory,
              _libraryDirectory,
              _mainBundleDirectory,
              _temporaryDirectory
              ];
}

- (BOOL)removeItemAtPath:(NSString *)path {
    
    NSURL *url = [NSURL URLWithString:path];
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:url.path error:&error];
    
    if (!success) {
        NSLog(@"Remove file %@ - error %@", url, error.localizedDescription);
    }
    
    return success;
}

#pragma mark - Search

- (NSArray *)listItemsInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    
    
    NSString *absolutePath = [self absolutePath:path];
    
    NSError *error = nil;
    NSArray *relativeSubpaths = (deep ?
                                 [self.fManager subpathsOfDirectoryAtPath:absolutePath error:&error] :
                                 [self.fManager contentsOfDirectoryAtPath:absolutePath error:&error]);
    if (error) {
        
        NSLog(@"Error %@", error.localizedDescription);
    }
    
    NSMutableArray *absoluteSubpaths = [NSMutableArray array];
    
    for (NSString *relativeSubpath in relativeSubpaths) {
        
        NSString *absoluteSubpath = [absolutePath stringByAppendingPathComponent:relativeSubpath];
        [absoluteSubpaths addObject:absoluteSubpath];
    }
    
    return [NSArray arrayWithArray:absoluteSubpaths];
}

#pragma mark - Utils

- (NSString *)absolutePath:(NSString *)path {
    
    [self assertPath:path];
    
    NSString *defaultDirectory = [self absoluteDirectoryForPath:path];
    
    if (defaultDirectory != nil) {
        
        return path;
    }
    else {
        
        return [self.documentsDirectory stringByAppendingPathComponent:path];
    }
}

- (void)assertPath:(NSString *)path {
    
    NSAssert(path != nil, @"Invalid path. Path cannot be nil.");
    NSAssert(![path isEqualToString:@""], @"Invalid path. Path cannot be empty string.");
}

- (NSString *)absoluteDirectoryForPath:(NSString *)path {
    
    [self assertPath:path];
    
    if([path isEqualToString:@"/"]) {
        
        return nil;
    }
    
    for (NSString *directory in self.dirs) {
        
        NSRange indexOfDirectoryInPath = [path rangeOfString:directory];
        
        if (indexOfDirectoryInPath.location == 0) {
            
            return directory;
        }
    }
    
    return nil;
}

#pragma mark - Information

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path {
    
    NSError *error = nil;
    NSDictionary *attrs = [self.fManager attributesOfItemAtPath:path error:&error];
    
    if (error) {
        NSLog(@"attributesOfItemAtPath: %@", error.localizedDescription);
    }
    
    return attrs;
}

- (NSDictionary *)xattrOfItemAtPath:(NSString *)path {
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    
    const char *upath = [path UTF8String];
    
    ssize_t ukeysSize = listxattr(upath, NULL, 0, 0);
    
    if ( ukeysSize > 0 ) {
        
        char *ukeys = malloc(ukeysSize);
        
        ukeysSize = listxattr(upath, ukeys, ukeysSize, 0);
        
        NSUInteger keyOffset = 0;
        NSString *key;
        NSString *value;
        
        while (keyOffset < ukeysSize) {
            
            key = [NSString stringWithUTF8String:(keyOffset + ukeys)];
            keyOffset += ([key length] + 1);
            
            value = [self xattrOfItemAtPath:path getValueForKey:key];
            values[key] = value;
        }
        
        free(ukeys);
    }
    
    return values.copy;
}

- (NSString *)xattrOfItemAtPath:(NSString *)path getValueForKey:(NSString *)key {
    
    NSString *value = nil;
    
    const char *ukey = [key UTF8String];
    const char *upath = [path UTF8String];
    
    ssize_t uvalueSize = getxattr(upath, ukey, NULL, 0, 0, 0);
    
    if ( uvalueSize > -1 ) {
        
        if ( uvalueSize == 0 ) {
            
            value = @"";
        }
        else {
            
            char *uvalue = malloc(uvalueSize);
            
            if ( uvalue ) {
                
                getxattr(upath, ukey, uvalue, uvalueSize, 0, 0);
                uvalue[uvalueSize] = '\0';
                value = [NSString stringWithUTF8String:uvalue];
                free(uvalue);
            }
        }
    }
    
    return value;
}

@end
